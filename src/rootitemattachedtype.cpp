#include "rootitemattachedtype.h"
#include <QDebug>

QQuickItem* RootItemAttachedType::mpContentItem = nullptr;
QQuickItem* RootItemAttachedType::mpHeader = nullptr;
QQuickItem* RootItemAttachedType::mpFooter = nullptr;

RootItemAttachedType::RootItemAttachedType(QObject *parent) : QObject(parent) {}

QQuickItem *RootItemAttachedType::getContentItem() {

  return mpContentItem;
}

void RootItemAttachedType::setContentItem(QQuickItem *root) {

  mpContentItem = root;
  emit contentItemChanged(mpContentItem);
}

QQuickItem *RootItemAttachedType::getHeader() {

  return mpHeader;
}

void RootItemAttachedType::setHeader(QQuickItem *root) {

  mpHeader = root;
  emit headerChanged(mpHeader);
}

QQuickItem *RootItemAttachedType::getFooter() {

  return mpFooter;
}

void RootItemAttachedType::setFooter(QQuickItem *root) {

  mpFooter = root;
  emit footerChanged(mpFooter);
}
