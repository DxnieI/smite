#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>

class UserViewModel;

class LibraryViewModel : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
  Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
  Q_PROPERTY(QVariantList games READ games NOTIFY gamesChanged)

public:
  explicit LibraryViewModel(QObject *parent = nullptr);
  explicit LibraryViewModel(UserViewModel *userViewModel, QObject *parent = nullptr);

  // Property getters
  bool isLoading() const { return m_isLoading; }
  QString errorMessage() const { return m_errorMessage; }
  QVariantList games() const { return m_games; }

  // Invokable methods for QML
  Q_INVOKABLE void refreshLibrary();
  Q_INVOKABLE void clearErrorMessage();

Q_SIGNALS:
  void isLoadingChanged();
  void errorMessageChanged();
  void gamesChanged();

private Q_SLOTS:
  void onUserLoginChanged();

private:
  void setIsLoading(bool value);
  void setErrorMessage(const QString &value);
  void setGames(const QVariantList &value);
  void loadLibraryFast();
  void connectToUserViewModel(UserViewModel *userViewModel);

  bool m_isLoading;
  QString m_errorMessage;
  QVariantList m_games;
  bool m_wasLoggedIn;
  UserViewModel *m_userViewModel;
};
