import os
import random
import string
import platform

IS_WIN = platform.system() == 'Windows'

from PyQt6.QtCore import pyqtSlot, pyqtProperty, pyqtSignal, QObject, QUrl, QThread
from PyQt6.QtGui import QDesktopServices
from PyQt6.QtWidgets import QApplication
from PyQt6.QtSql import QSqlQuery

import sql
import thumbnails
import misc
import git

SOURCE_REPO = "https://github.com/arenasys/PyQt6-QML-Template"

class Update(QThread):
    def run(self):
        git.gitReset(".", SOURCE_REPO)

class GUI(QObject):
    updated = pyqtSignal()
    aboutToQuit = pyqtSignal()

    def __init__(self, parent):
        super().__init__(parent)
        self._db = sql.Database(self)
        self._thumbnails = thumbnails.ThumbnailStorage((256, 256), (640, 640), 75, self)
        parent.aboutToQuit.connect(self.stop)

        self._needRestart = False
        self._gitInfo = None
        self._gitCommit = None
        self._triedGitInit = False
        self._updating = False
        #self.getVersionInfo()

        self.conn = None
        self.populateDatabase()

    @pyqtProperty('QString', notify=updated)
    def title(self):
        return "Template"

    @pyqtSlot()
    def stop(self):
        self.aboutToQuit.emit()

    @pyqtSlot()
    def quit(self):
        QApplication.quit()

    @pyqtSlot(str, result=bool)
    def isCached(self, file):
        return self._thumbnails.has(QUrl.fromLocalFile(file).toLocalFile(), (256,256))

    @pyqtSlot(str)
    def openPath(self, path):
        QDesktopServices.openUrl(QUrl.fromLocalFile(path))

    @pyqtSlot(str)
    def openLink(self, link):
        try:
            QDesktopServices.openUrl(QUrl.fromUserInput(link))
        except Exception:
            pass
    
    @pyqtSlot(list)
    def visitFiles(self, files):
        folder = os.path.dirname(files[0])
        if IS_WIN:
            try:
                misc.showFilesInExplorer(folder, files)
            except:
                pass
        else:
            self.openPath(folder)

    @pyqtProperty(str, notify=updated)
    def versionInfo(self):
        return self._gitInfo

    @pyqtProperty(bool, notify=updated)
    def needRestart(self):
        return self._needRestart
    
    @pyqtProperty(bool, notify=updated)
    def updating(self):
        return self._updating

    @pyqtSlot()
    def getVersionInfo(self):
        self._updating = False
        self._gitInfo = "Unknown"
        commit, label = git.gitLast(".")
        if commit:
            if self._gitCommit == None:
                self._gitCommit = commit
            self._gitInfo = label
            self._needRestart = self._gitCommit != commit
        elif not self._triedGitInit:
            self._triedGitInit = True
            git.gitInit(".", SOURCE_REPO)
        self.updated.emit()

    @pyqtSlot()
    def update(self):
        self._updating = True
        update = Update(self)
        update.finished.connect(self.getVersionInfo)
        update.start()
        self.updated.emit()

    @pyqtSlot()
    def populateDatabase(self):
        partial = True
        if not self.conn:
            self.conn = sql.Connection(self)
            self.conn.connect()
            self.conn.doQuery("CREATE TABLE data(a TEXT, b TEXT, idx INTEGER UNIQUE);")
            self.conn.enableNotifications("data")
            partial = False

        for i in range(1,100):
            if partial and random.SystemRandom().random() < 0.7:
                continue

            q = QSqlQuery(self.conn.db)
            q.prepare("INSERT OR REPLACE INTO data(a, b, idx) VALUES (:a, :b, :idx);")
            a = ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(8))
            b = ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(8))
            q.bindValue(":a", a)
            q.bindValue(":b", b)
            q.bindValue(":idx", i)
            self.conn.doQuery(q)
