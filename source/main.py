import warnings
warnings.filterwarnings("ignore", category=UserWarning) 
warnings.filterwarnings("ignore", category=DeprecationWarning) 

import sys
import signal
import traceback
import datetime
import subprocess
import os
import glob
import shutil
import importlib
import pkg_resources
import json
import hashlib

import platform
IS_WIN = platform.system() == 'Windows'

from PyQt6.QtCore import pyqtSignal, pyqtSlot, pyqtProperty, QObject, QUrl, QCoreApplication, Qt, QElapsedTimer, QThread
from PyQt6.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType, qmlRegisterType, qmlRegisterSingletonInstance
from PyQt6.QtWidgets import QApplication
from PyQt6.QtGui import QIcon

NAME = "template"
LAUNCHER = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "launcher.exe")
APPID = "arenasys.template." + hashlib.md5(LAUNCHER.encode("utf-8")).hexdigest()
ERRORED = False

class Application(QApplication):
    t = QElapsedTimer()

    def event(self, e):
        return QApplication.event(self, e)

def check(dependancies, enforce_version=True):
    importlib.reload(pkg_resources)
    needed = []
    for d in dependancies:
        try:
            pkg_resources.require(d)
        except pkg_resources.DistributionNotFound:
            needed += [d]
        except pkg_resources.VersionConflict as e:
            if enforce_version:
                #print("CONFLICT", d, e)
                needed += [d]
        except Exception:
            pass
    return needed

class Installer(QThread):
    output = pyqtSignal(str)
    installing = pyqtSignal(str)
    installed = pyqtSignal(str)
    def __init__(self, parent, packages):
        super().__init__(parent)
        self.packages = packages
        self.proc = None
        self.stopping = False

    def run(self):
        for p in self.packages:
            self.installing.emit(p)
            args = ["pip", "install", "-U", p]
            pkg = p.split("=",1)[0]
            if pkg in {"torch", "torchvision"}:
                args = ["pip", "install", "-U", pkg, "--index-url", "https://download.pytorch.org/whl/" + p.rsplit("+",1)[-1]]
            args = [sys.executable, "-m"] + args

            startupinfo = None
            if IS_WIN:
                startupinfo = subprocess.STARTUPINFO()
                startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW

            self.proc = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, env=os.environ, startupinfo=startupinfo)

            output = ""
            while self.proc.poll() == None:
                while line := self.proc.stdout.readline():
                    if line:
                        line = line.strip()
                        output += line + "\n"
                        self.output.emit(line)
                    if self.stopping:
                        return
            if self.stopping:
                return
            if self.proc.returncode:
                raise RuntimeError("Failed to install: ", p, "\n", output)
            
            self.installed.emit(p)
        self.proc = None

    @pyqtSlot()
    def stop(self):
        self.stopping = True
        if self.proc:
            self.proc.kill()

class Coordinator(QObject):
    ready = pyqtSignal()
    show = pyqtSignal()
    proceed = pyqtSignal()
    cancel = pyqtSignal()

    output = pyqtSignal(str)

    updated = pyqtSignal()
    installedUpdated = pyqtSignal()
    def __init__(self, app, engine):
        super().__init__(app)
        self.app = app
        self.engine = engine
        self.installer = None

        self._needRestart = False
        self._installed = []
        self._installing = ""

        self.in_venv = "VIRTUAL_ENV" in os.environ
        self.override = False
        self.enforce = True

        with open(os.path.join("source", "requirements.txt")) as file:
            self.required = [line.rstrip() for line in file]

        self.findNeeded()

        qmlRegisterSingletonType(Coordinator, "gui", 1, 0, lambda qml, js: self, "COORDINATOR")

    @pyqtProperty(list, constant=True)
    def modes(self):
        return ["Nvidia", "AMD", "Remote"]

    @pyqtProperty(list, notify=updated)
    def packages(self):
        return self.getNeeded()
    
    @pyqtProperty(list, notify=installedUpdated)
    def installed(self):
        return self._installed
    
    @pyqtProperty(str, notify=installedUpdated)
    def installing(self):
        return self._installing
    
    @pyqtProperty(bool, notify=installedUpdated)
    def disable(self):
        return self.installer != None
    
    @pyqtProperty(bool, notify=updated)
    def needRestart(self):
        return self._needRestart

    def findNeeded(self):
        self.required_need = check(self.required, self.enforce)

    def getNeeded(self):
        needed = self.required_need
        needed = [n for n in needed if n.startswith("wheel")] + [n for n in needed if not n.startswith("wheel")]
        needed = [n for n in needed if n.startswith("pip")] + [n for n in needed if not n.startswith("pip")]
        return needed

    @pyqtSlot()
    def load(self):
        self.app.setWindowIcon(QIcon("source/qml/icons/placeholder_color.svg"))
        self.loaded()

    @pyqtSlot()
    def loaded(self):
        ready()
        self.ready.emit()

        if self.in_venv and self.packages:
            self.show.emit()
        else:
            self.done()
        
    @pyqtSlot()
    def done(self):
        start(self.engine, self.app)
        self.proceed.emit()

    @pyqtSlot()
    def install(self):
        if self.installer:
            self.cancel.emit()
            return
        packages = self.packages
        if not packages:
            self.done()
            return
        self.installer = Installer(self, packages)
        self.installer.installed.connect(self.onInstalled)
        self.installer.installing.connect(self.onInstalling)
        self.installer.output.connect(self.onOutput)
        self.installer.finished.connect(self.doneInstalling)
        self.app.aboutToQuit.connect(self.installer.stop)
        self.cancel.connect(self.installer.stop)
        self.installer.start()
        self.installedUpdated.emit()

    @pyqtSlot(str)
    def onInstalled(self, package):
        self._installed += [package]
        self.installedUpdated.emit()
    
    @pyqtSlot(str)
    def onInstalling(self, package):
        self._installing = package
        self.installedUpdated.emit()
    
    @pyqtSlot(str)
    def onOutput(self, out):
        self.output.emit(out)
    
    @pyqtSlot()
    def doneInstalling(self):
        self._installing = ""
        self.installer = None
        self.installedUpdated.emit()
        self.findNeeded()
        if not self.packages:
            self.done()
            return
        self.installer = None
        self.installedUpdated.emit()
        if all([p in self._installed for p in self.packages]):
            self._needRestart = True
            self.updated.emit()

    @pyqtProperty(float, constant=True)
    def scale(self):
        if IS_WIN:
            factor = round(self.parent().desktop().logicalDpiX()*(100/96))
            if factor == 125:
                return 0.82
        return 1.0
    
def launch():
    import misc
    if IS_WIN:
        misc.setAppID(APPID)
    
    #QCoreApplication.setAttribute(Qt.AA_UseDesktopOpenGL, True)
    #QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling, True)
    #QCoreApplication.setAttribute(Qt.AA_UseHighDpiPixmaps, True)

    scaling = False
    if scaling:
        QApplication.setHighDpiScaleFactorRoundingPolicy(Qt.HighDpiScaleFactorRoundingPolicy.PassThrough)

    app = Application([NAME])
    signal.signal(signal.SIGINT, lambda sig, frame: app.quit())
    app.startTimer(100)

    app.setOrganizationName(NAME)
    app.setOrganizationDomain(NAME)
    
    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)
    
    coordinator = Coordinator(app, engine)

    engine.load(QUrl('file:source/qml/Splash.qml'))

    if IS_WIN:
        hwnd = engine.rootObjects()[0].winId()
        misc.setWindowProperties(hwnd, APPID, NAME, LAUNCHER)

    os._exit(app.exec())

def ready():
    import misc
    common_path = QUrl.fromLocalFile(os.path.abspath(os.path.join("source", "qml", "Common.qml")))
    qmlRegisterSingletonType(common_path, "gui", 1, 0, "COMMON")
    misc.registerTypes()

def start(engine, app):
    import gui
    import sql

    sql.registerTypes()

    backend = gui.GUI(parent=app)

    engine.addImageProvider("sync", backend._thumbnails.sync_provider)
    engine.addImageProvider("async", backend._thumbnails.async_provider)
    engine.addImageProvider("big", backend._thumbnails.big_provider)

    qmlRegisterSingletonType(gui.GUI, "gui", 1, 0, lambda qml, js: backend, "GUI")

def exceptHook(exc_type, exc_value, exc_tb):
    global ERRORED
    tb = "".join(traceback.format_exception(exc_type, exc_value, exc_tb))
    with open("crash.log", "a", encoding='utf-8') as f:
        f.write(f"GUI {datetime.datetime.now()}\n{tb}\n")
    print(tb)
    print("TRACEBACK SAVED: crash.log")

    if IS_WIN and os.path.exists(LAUNCHER) and not ERRORED:
        ERRORED = True
        message = f"{tb}\nError saved to crash.log"
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        subprocess.run([LAUNCHER, "-e", message], startupinfo=startupinfo)

    QApplication.exit(-1)

def main():
    sys.excepthook = exceptHook
    launch()

if __name__ == "__main__":
    main()