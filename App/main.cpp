#include <iostream>
#include <core/commands.h>
#include <string>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

using namespace Core;

int main(int argc, char *argv[]) {
    // Create the list command
    LegendaryCommand cmd = LegendaryCommand::listWithPlatform(
        LegendaryPlatform::windows());

    // Get arguments and print them
    for (auto args = cmd.toArguments(BaseCommandOptions::init()); const auto &arg: args) {
        auto str = static_cast<std::string>(arg);
        std::cout << str << std::endl;
    }

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();

}
