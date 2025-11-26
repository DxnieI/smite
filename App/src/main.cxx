#include <KIconTheme>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QtQml>
#include "viewmodels/UserViewModel.h"
#include "viewmodels/LibraryViewModel.h"
#include <QtWebEngineQuick>
#include "CachingNetworkAccessManager.h"

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

  // Set up network access manager with disk cache
  engine.setNetworkAccessManagerFactory(new CachingNetworkAccessManagerFactory());

  // Register ViewModels
  qmlRegisterType<UserViewModel>("xyz.dxniel.smite", 1, 0, "UserViewModel");
  qmlRegisterType<LibraryViewModel>("xyz.dxniel.smite", 1, 0, "LibraryViewModel");

  // Create global view model instances
  UserViewModel globalUserViewModel;
  LibraryViewModel globalLibraryViewModel(&globalUserViewModel);

  // Set context properties for QML access
  engine.rootContext()->setContextProperty(QStringLiteral("globalUserViewModel"), &globalUserViewModel);
  engine.rootContext()->setContextProperty(QStringLiteral("globalLibraryViewModel"), &globalLibraryViewModel);

  engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
  engine.loadFromModule("xyz.dxniel.smite", "Main");

  if (engine.rootObjects().isEmpty()) {
    return -1;
  }

  return app.exec();
}