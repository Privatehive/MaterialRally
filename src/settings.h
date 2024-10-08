/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QVariant>
#include <QtQml/qqmlregistration.h>
#include "MaterialRallyExport.h"

/**
 * This class contains global kirigami settings about the current device setup
 * It is exposed to QML as the singleton "Settings"
 */
class MATERIALRALLY_EXPORT Settings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    /**
     * This property holds whether the system can dynamically enter and exit tablet mode
     * (or the device is actually a tablet).
     * This is the case for foldable convertibles and transformable laptops that support
     * keyboard detachment.
     */
    Q_PROPERTY(bool tabletModeAvailable READ isTabletModeAvailable NOTIFY tabletModeAvailableChanged)

    /**
     * This property holds whether the application is running on a small mobile device
     * such as a mobile phone. This is used when we want to do specific adaptations to
     * the UI for small screen form factors, such as having bigger touch areas.
     */
    Q_PROPERTY(bool isMobile READ isMobile NOTIFY isMobileChanged)

    /**
     * This property holds whether the application is running on a device that is
     * behaving like a tablet.
     *
     * @note This doesn't mean exactly a tablet form factor, but
     * that the preferred input mode for the device is the touch screen
     * and that pointer and keyboard are either secondary or not available.
     */
    Q_PROPERTY(bool tabletMode READ tabletMode NOTIFY tabletModeChanged)

    /**
     * This property holds whether the system has a platform menu bar; e.g. a user is
     * on macOS or has a global menu on KDE Plasma.
     *
     * @warning Android has a platform menu bar; which may not be what you expected.
     */
    Q_PROPERTY(bool hasPlatformMenuBar READ hasPlatformMenuBar CONSTANT)

    /**
     * This property holds whether the user in this moment is interacting with the app
     * with the touch screen.
     */
    Q_PROPERTY(bool hasTransientTouchInput READ hasTransientTouchInput NOTIFY hasTransientTouchInputChanged)

    /**
     * This property holds the name of the QtQuickControls2 style the application is using,
     * for instance org.kde.desktop, Plasma, Material, Universal etc
     */
    Q_PROPERTY(QString style READ style CONSTANT)

    // TODO: make this adapt without file watchers?
    /**
     * This property holds the number of lines of text the mouse wheel should scroll.
     */
    Q_PROPERTY(int mouseWheelScrollLines READ mouseWheelScrollLines CONSTANT)

    /**
     * This property holds the runtime information about the libraries in use.
     *
     * @since 5.52
     * @since org.kde.kirigami 2.6
     */
    Q_PROPERTY(QStringList information READ information CONSTANT)

    /**
     * This property holds the name of the application window icon.
     * @see QGuiApplication::windowIcon()
     *
     * @since 5.62
     * @since org.kde.kirigami 2.10
     */
    Q_PROPERTY(QVariant applicationWindowIcon READ applicationWindowIcon CONSTANT)

public:
    Settings(QObject *parent = nullptr);
    ~Settings() override;

    void setTabletModeAvailable(bool mobile);
    bool isTabletModeAvailable() const;

    void setIsMobile(bool mobile);
    bool isMobile() const;

    void setTabletMode(bool tablet);
    bool tabletMode() const;

    void setTransientTouchInput(bool touch);
    bool hasTransientTouchInput() const;

    bool hasPlatformMenuBar() const;

    QString style() const;
    void setStyle(const QString &style);

    int mouseWheelScrollLines() const;

    QStringList information() const;

    QVariant applicationWindowIcon() const;

    static Settings *self();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
    void tabletModeAvailableChanged();
    void tabletModeChanged();
    void isMobileChanged();
    void hasTransientTouchInputChanged();

private:
    QString m_style;
    int m_scrollLines = 0;
    bool m_tabletModeAvailable : 1;
    bool m_mobile : 1;
    bool m_tabletMode : 1;
    bool m_hasTouchScreen : 1;
    bool m_hasTransientTouchInput : 1;
    bool m_hasPlatformMenuBar : 1;
};

#endif
