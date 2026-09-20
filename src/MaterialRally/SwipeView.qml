import QtQml
import QtQuick as T
import "flingphysics.js" as FlingPhysics


/*!
    \qmltype SwipeView
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Item

    \brief A horizontally paged container, swiped between with a finger - built entirely on Qt
    Quick Input Handlers (DragHandler), no MouseArea, no QtQuick.Controls.SwipeView/Flickable.

    Rally.SwipeView is a drop-in-familiar replacement for QtQuick.Controls.SwipeView: pages are
    declared as children, currentIndex tracks/drives which page is shown, and swiping snaps to
    the nearest page on release - or, if released with enough velocity, commits to the next/
    previous page even from a small drag (matching Android's ViewPager "fling to turn the page"
    feel), reusing the same release-velocity tracking approach as Rally.Flickable.

    Pages are automatically sized to fill the SwipeView (width/height bound to it), matching
    stock SwipeView's behavior.

    Unlike QtQuick.Controls.SwipeView, there is no attached SwipeView.isCurrentItem/isNextItem/
    isPreviousItem - compare a delegate's own index against currentIndex directly instead, e.g.
    a lazy Loader's \c{active: Math.abs(index - view.currentIndex) <= 1}.

    Like Rally.Flickable, dragging to change pages is a touch (and stylus) gesture only - mouse/
    touchpad users are expected to navigate via whatever UI drives currentIndex (e.g. tab
    buttons), not by dragging the page content itself.

    Being DragHandler-based rather than Flickable-based is also what makes this safe to nest
    inside a vertically scrolling Rally.ScrollView. QQuickFlickable decides to steal a drag from
    \c{|dx|} alone (qquickflickable.cpp, handleMoveEvent: it tests deltas.x() against the drag
    threshold and never compares it to deltas.y()), so a stock horizontal SwipeView hijacks
    vertical scrolls; and once it has grabbed, an ancestor cannot take the grab back, because
    QQuickPointerHandler::approveGrabTransition() only lets a handler steal from an item that is
    its *ancestor*, not from a descendant holding keepTouchGrab. QQuickDragHandler instead
    refuses to activate at all when the drag is mostly along its disabled axis
    (handlePointerEventImpl: "If vertical dragging is disallowed, but the user is dragging mostly
    vertically, then don't activate"), which is the axis arbitration this nesting needs.
*/
T.Item {

    id: control

    clip: true

    // Matches stock SwipeView (a Container subclass): when not given an explicit size, it sizes
    // itself to fit whichever page is current - needed for usage like the Gallery's own
    // ScrollView-wrapped page switcher, which only constrains width and expects the SwipeView's
    // own height to track its (page-height-dependent) content.
    implicitWidth: currentItem ? currentItem.implicitWidth : 0
    implicitHeight: currentItem ? currentItem.implicitHeight : 0

    /*!
      The pages of this SwipeView. This is the default property. Each page's width/height is
      automatically bound to match the SwipeView's own (like stock SwipeView), overriding
      whatever size the page declared. A Repeater is fine as a direct child (its generated
      delegates are counted as pages, the Repeater itself isn't) - count/currentItem/page sizing
      all derive from the internal Row's actual resolved children, not this raw declared list.
    */
    default property list<QtObject> contentChildren

    /*!
      Number of pages. Derived from pagesRow.children (the Row's actual resolved children, so a
      Repeater declared as a page source expands into its generated delegates here) with any
      Repeater instances themselves filtered out - unlike a Positioner's own layout, Item.children
      is a plain structural list that includes the Repeater object itself alongside its
      delegates, so it has to be excluded explicitly (verified empirically; Qt Quick source
      wasn't available to confirm directly).
    */
    readonly property int count: _pageList.length

    /*!
      The page at currentIndex, or null if currentIndex is out of range (e.g. no pages yet).
    */
    readonly property T.Item currentItem: (currentIndex >= 0 && currentIndex < _pageList.length)
                                          ? _pageList[currentIndex] : null

    // The resolved page list, refreshed only when pageStrip's children actually change. Holding
    // it in a typed list rather than recomputing it inside count/currentItem keeps both of those
    // AOT-compilable - _scanPages() itself cannot be, because qmlcachegen has no instruction for
    // `instanceof` ("generate_CmpInstanceOf not implemented"), and it would otherwise poison
    // every binding that touched it.
    property list<T.Item> _pageList

    /*!
      The resolved pages, in order. Cheap - returns the cached list.
    */
    function _pages(): list<T.Item> {
        return control._pageList
    }

    // Item.children is a plain structural list that includes a declared Repeater alongside the
    // delegates it generated, unlike a Positioner's own layout, so the Repeater has to be
    // excluded explicitly (verified empirically; Qt Quick source wasn't available to confirm
    // directly).
    function _scanPages() {
        var result = []
        for (var i = 0; i < pageStrip.children.length; i++) {
            var child = pageStrip.children[i]
            if (!(child instanceof T.Repeater))
                result.push(child)
        }
        return result
    }

    /*!
      \qmlproperty int SwipeView::currentIndex
      \default 0

      The index of the page currently shown. Settable to navigate programmatically (e.g. from a
      tab bar) - doing so animates to the target page the same way a swipe gesture would.
    */
    property int currentIndex: 0

    property bool interactive: true

    /*!
      Gap, in px, between adjacent pages.
    */
    property real spacing: 0

    /*!
      \qmlproperty real SwipeView::flingCommitVelocity
      \default 400

      Release velocity, in px/s, above which a swipe commits to the next/previous page even if
      dragged less than halfway across - matches the "fling to turn the page" feel of Android's
      ViewPager/ViewPager2. A slow drag released below this speed instead just snaps to whichever
      page is closer.
    */
    property real flingCommitVelocity: 400

    /*!
      Duration, in ms, of the settle animation that snaps to a page after a drag ends or
      currentIndex is set programmatically.
    */
    property int settleDuration: 250

    readonly property bool atFirstPage: currentIndex <= 0
    readonly property bool atLastPage: currentIndex >= count - 1

    readonly property bool dragging: dragHandler.active
    readonly property bool moving: dragging || settleAnim.running

    readonly property real _pageStep: width + spacing
    property real _rowX: -currentIndex * _pageStep
    property bool _dragging: false
    // currentIndex at the moment the current drag began - the fling-commit target in
    // _commitDragEnd is capped to within one page of this, not derived solely from the raw
    // release-time drag position (see _commitDragEnd for why).
    property int _dragStartIndex: 0

    onWidthChanged: {
        if (!control._dragging && !settleAnim.running)
            control._rowX = -control.currentIndex * control._pageStep
    }

    // Guarded on _pageStep > 0: during initial construction, custom properties like
    // currentIndex get their declared value (and fire this handler) before built-in geometry
    // properties like width do, so _pageStep is still 0 the first time this could fire. Starting
    // a settle animation at that point - even a "no-op" 0-to-0 one, since width isn't known yet
    // - would claim _rowX for the animation's full duration, which both breaks _rowX's own
    // initial live binding *and* blocks onWidthChanged's guarded correction above (its
    // `!settleAnim.running` check would then be false) from fixing it once the real width
    // arrives - permanently stranding _rowX at 0. Skipping the settle here instead leaves
    // _rowX's own binding (-currentIndex * _pageStep) live and in control until a real,
    // post-construction settle is actually needed.
    onCurrentIndexChanged: {
        if (!control._dragging && control._pageStep > 0)
            control._settleTo(control.currentIndex)
    }

    // Reacts to pagesRow's resolved children list changing - covers both the initial set of
    // declared pages and any that appear/disappear later (e.g. a Repeater's model changing),
    // unlike a one-time Component.onCompleted loop which would only ever see the startup set.
    function _onPagesChanged() {
        const scanned = control._scanPages()
        // childrenChanged fires for changes that leave the page set alone (a Repeater
        // re-parenting, a page toggling visibility). Re-binding then would drop and recreate
        // three bindings per page for nothing, so only do the work when the list really moved.
        if (!control._samePages(scanned))
            control._bindPageSizes(scanned)
        if (control.currentIndex > control.count - 1)
            control.currentIndex = Math.max(0, control.count - 1)
    }

    function _samePages(scanned): bool {
        const current = control._pageList
        if (current.length !== scanned.length)
            return false
        for (let i = 0; i < scanned.length; i++) {
            if (current[i] !== scanned[i])
                return false
        }
        return true
    }

    function _bindPageSizes(pages) {
        // Pages fill the SwipeView, matching stock SwipeView - bind each page's size to ours
        // (overriding whatever it declared) rather than requiring every page to set width/
        // height bindings manually, the way Rally.Flickable's own content does (a SwipeView's
        // pages are always meant to fill it; a Flickable's content isn't). Re-binding an
        // already-bound page here is harmless/idempotent, so this doesn't need to track which
        // pages were already done.
        //
        // x is bound here too, by index, rather than letting a positioner do it. pageStrip used
        // to be a Row, and QQuickPositioner omits explicitly-hidden children from layout and
        // re-packs the rest (qquickpositioners.cpp: "Items are only omitted from positioning if
        // they are explicitly hidden"). A lazily-loaded page - e.g. the Gallery's
        // `visible: status == Loader.Ready` Loaders - is invisible until it loads, so unloading
        // page 0 slid every later page one slot left while _rowX still assumed fixed slots,
        // putting the current page off-screen and rendering blank. Explicit per-index placement
        // makes the strip independent of any page's visibility.
        for (let i = 0; i < pages.length; i++) {
            const page = pages[i]
            const index = i     // fresh binding per iteration - a `var` here would capture the
                                // loop variable and give every page the last index
            page.width = Qt.binding(function () { return control.width })
            page.height = Qt.binding(function () { return control.height })
            page.x = Qt.binding(function () { return index * control._pageStep })
            page.y = 0
        }
        control._pageList = pages
    }

    function _clamp(value: real, min: real, max: real): real {
        return Math.max(min, Math.min(value, max))
    }

    function _clampIndex(index: int): int {
        return control._clamp(index, 0, Math.max(0, control.count - 1))
    }

    function _indexAtRowX(): int {
        if (control._pageStep <= 0)
            return control.currentIndex
        return control._clampIndex(Math.round(-control._rowX / control._pageStep))
    }

    function _settleTo(index: int) {
        settleAnim.stop()
        settleAnim.to = -control._clampIndex(index) * control._pageStep
        settleAnim.start()
    }

    function _applyPageDrag(dx: real) {
        var minX = -(control.count - 1) * control._pageStep
        control._rowX = control._clamp(control._rowX + dx, minX, 0)
        control.currentIndex = control._indexAtRowX()
    }

    function _commitDragEnd(velocity: real) {
        var target
        if (Math.abs(velocity) >= control.flingCommitVelocity && control._pageStep > 0) {
            var rawIndex = -control._rowX / control._pageStep
            // dx/velocity follow the finger directly (see _applyPageDrag): dragging/flinging
            // right reveals the previous page, left reveals the next one.
            target = velocity < 0 ? Math.floor(rawIndex) + 1 : Math.ceil(rawIndex) - 1
            // A fast swipe's raw drag position at release can already have carried slightly past
            // the very page it just revealed (the finger's velocity doesn't stop the instant the
            // target page is fully visible) - floor/ceil above would then commit one page further
            // than intended. Matches Android ViewPager/ViewPager2: a fling never advances more
            // than one page from wherever the gesture started, no matter how far the raw position
            // traveled.
            target = control._clamp(target, control._dragStartIndex - 1, control._dragStartIndex + 1)
        } else {
            target = control._indexAtRowX()
        }
        target = control._clampIndex(target)
        control.currentIndex = target
        control._settleTo(target)
    }

    // Deliberately a plain Item and not a Row: see _bindPageSizes for why a positioner cannot be
    // used here. Pages are placed explicitly by index, so `spacing` only feeds _pageStep.
    T.Item {

        id: pageStrip

        x: control._rowX
        width: control.width
        height: control.height

        data: control.contentChildren

        // Deferred via Qt.callLater (which coalesces repeated calls with the same function
        // reference into one) rather than reacting synchronously: during initial construction,
        // childrenChanged fires once per page as each is reparented in, so reacting immediately
        // means count/currentIndex-clamping see a transient, incomplete page list and can
        // incorrectly clamp/reset currentIndex before the real page set has fully settled.
        onChildrenChanged: Qt.callLater(control._onPagesChanged)
    }

    T.DragHandler {

        id: dragHandler

        target: null
        enabled: control.interactive && control.count > 1
        // Matches Rally.Flickable: dragging to page is a touch/stylus gesture only.
        acceptedDevices: T.PointerDevice.AllDevices & ~T.PointerDevice.Mouse & ~T.PointerDevice.TouchPad
        // Leaving yAxis disabled is not just "we don't scroll vertically" - it is what makes this
        // nestable inside a vertical Rally.ScrollView. QQuickDragHandler refuses to activate when
        // the drag is mostly along a disabled axis, so a vertical drag never becomes a page swipe.
        // See the type docs above.
        xAxis.enabled: true
        yAxis.enabled: false

        // Shared with Rally.Flickable - see FlingPhysics.VelocityTracker for why a smoothed
        // estimate like centroid.velocity is not good enough here, which is what
        // flingCommitVelocity needs to judge accurately. Allocated once; recording a sample
        // allocates nothing, unlike the {x, t} object literal plus Array.shift() this replaces,
        // which ran on every single touch move.
        readonly property var _tracker: new FlingPhysics.VelocityTracker(60)

        onActiveChanged: {
            if (dragHandler.active) {
                dragHandler._tracker.reset()
                control._dragStartIndex = control.currentIndex
                control._dragging = true
                settleAnim.stop()
            } else {
                control._dragging = false
                dragHandler._tracker.compute()
                control._commitDragEnd(dragHandler._tracker.vx)
            }
        }

        onActiveTranslationChanged: {
            const tr = dragHandler._tracker
            const tx = dragHandler.activeTranslation.x
            const dx = tx - tr.lastX
            tr.record(tx, 0)
            control._applyPageDrag(dx)
        }

        // Stop an in-flight settle as soon as a finger goes down, before the drag threshold is
        // crossed. Same approach and same reason as Rally.Flickable's dragHandler: a TapHandler
        // cannot do this job, because QQuickSinglePointHandler::wantsPointerEvent() skips any
        // point that already has an exclusive grabber. Guarding on centroid.id rather than
        // centroid.pressedButtons matters - pressedButtons is Qt.NoButton for touch, so the
        // earlier `pressedButtons !== 0` test never fired for the only input this handler accepts.
        onCentroidChanged: {
            if (settleAnim.running && dragHandler.centroid.id !== -1)
                settleAnim.stop()
        }
    }

    T.NumberAnimation {
        id: settleAnim
        target: control
        property: "_rowX"
        duration: control.settleDuration
        easing.type: T.Easing.OutCubic
    }
}
