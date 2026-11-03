#pragma once

#include "MaterialRallyExport.h"

namespace MaterialRally {

/*!
 * \brief Makes the MaterialRally style configuration available to QtQuick.Controls.
 *
 * Call it before the first QML engine is created. The library embeds the qtquickcontrols2.conf
 * (Material style, theme, font) that QtQuick.Controls reads when it picks the style. Referencing
 * this function makes sure the library is loaded at application start - otherwise some linkers
 * (e.g. on Windows) drop the library if no symbol of it is used and it is loaded too late by the
 * QML engine.
 */
MATERIALRALLY_EXPORT void init();

} // namespace MaterialRally
