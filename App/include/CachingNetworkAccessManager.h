#pragma once

#include <QNetworkDiskCache>
#include <QNetworkAccessManager>
#include <QStandardPaths>
#include <QQmlNetworkAccessManagerFactory>
#include <QDebug>

// Network access manager factory that enables a disk cache for network requests.
class CachingNetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory {
public:
    QNetworkAccessManager *create(QObject *parent) override {
        auto *manager = new QNetworkAccessManager(parent);

        auto *cache = new QNetworkDiskCache(manager);
        QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
        cacheDir += QStringLiteral("/images");
        cache->setCacheDirectory(cacheDir);
        cache->setMaximumCacheSize(100 * 1024 * 1024);

        manager->setCache(cache);

        qDebug() << "Network cache enabled at:" << cacheDir;

        return manager;
    }
};
