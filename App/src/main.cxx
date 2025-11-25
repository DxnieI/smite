#include <KIconTheme>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QtQml>
#include "viewmodels/UserViewModel.h"
#include <QtWebEngineQuick>

int main(int argc, char *argv[]) {

  KIconTheme::initTheme();
  QtWebEngineQuick::initialize();
  QApplication app(argc, argv);

  KLocalizedString::setApplicationDomain("smite");
  QApplication::setOrganizationName(QStringLiteral("KDE"));
  QApplication::setOrganizationDomain(QStringLiteral("kde.org"));
  QApplication::setApplicationName(QStringLiteral("smite"));
  QApplication::setDesktopFileName(QStringLiteral("xyz.dxniel.smite"));

  QApplication::setStyle(QStringLiteral("breeze"));
  if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
    QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
  }

  QQmlApplicationEngine engine;

  qmlRegisterType<UserViewModel>("xyz.dxniel.smite", 1, 0, "UserViewModel");
  UserViewModel globalUserViewModel;
  engine.rootContext()->setContextProperty(QStringLiteral("globalUserViewModel"), &globalUserViewModel);

  engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
  engine.loadFromModule("xyz.dxniel.smite", "Main");

  if (engine.rootObjects().isEmpty()) {
    return -1;
  }

  return app.exec();
}