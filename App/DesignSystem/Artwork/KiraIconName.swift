/**
 The design system's icon names (index.d.ts IconName) and the SF Symbol each is drawn with on iOS,
 as the Icon README maps them. `minus` and `star` are not in the README: they map to the symbols of
 the same name. `upload` and `share` share one symbol, as the README says.
 */

/** A design-system icon, drawn with its SF Symbol. */
enum KiraIconName: String, CaseIterable {
    case home, chat, target, users
    case chevronRight = "chevron-right"
    case chevronLeft = "chevron-left"
    case chevronDown = "chevron-down"
    case calculator, close, eye
    case eyeOff = "eye-off"
    case camera, mic
    case arrowUp = "arrow-up"
    case trendUp = "trend-up"
    case heart, pencil, info, check, plus, wallet, phone, lock, receipt, search, bell, settings, user
    case shield, upload, download, file, calendar, external, flag
    case mapPin = "map-pin"
    case trash, book, chart, clock, share, copy, alert, help, logout, link, card, bank, sparkle, stop
    case refresh, filter, minus, star, key
    case faceID = "face-id"
    case scan, image, play, pause, wind, list, globe, gift
    case arrowRight = "arrow-right"
    case more, percent, send

    /** The SF Symbol for this icon. */
    var systemName: String {
        switch self {
        case .home: "house"
        case .chat: "bubble.left"
        case .target: "target"
        case .users: "person.2"
        case .chevronRight: "chevron.right"
        case .chevronLeft: "chevron.left"
        case .chevronDown: "chevron.down"
        case .calculator: "function"
        case .close: "xmark"
        case .eye: "eye"
        case .eyeOff: "eye.slash"
        case .camera: "camera"
        case .mic: "mic"
        case .arrowUp: "arrow.up"
        case .trendUp: "chart.line.uptrend.xyaxis"
        case .heart: "heart"
        case .pencil: "pencil"
        case .info: "info.circle"
        case .check: "checkmark"
        case .plus: "plus"
        case .wallet: "wallet.bifold"
        case .phone: "phone"
        case .lock: "lock"
        case .receipt: "receipt"
        case .search: "magnifyingglass"
        case .bell: "bell"
        case .settings: "slider.horizontal.3"
        case .user: "person"
        case .shield: "checkmark.shield"
        case .upload, .share: "square.and.arrow.up"
        case .download: "square.and.arrow.down"
        case .file: "doc.text"
        case .calendar: "calendar"
        case .external: "arrow.up.forward.square"
        case .flag: "flag"
        case .mapPin: "mappin"
        case .trash: "trash"
        case .book: "book"
        case .chart: "chart.bar"
        case .clock: "clock"
        case .copy: "doc.on.doc"
        case .alert: "exclamationmark.triangle"
        case .help: "questionmark.circle"
        case .logout: "rectangle.portrait.and.arrow.right"
        case .link: "link"
        case .card: "creditcard"
        case .bank: "building.columns"
        case .sparkle: "sparkle"
        case .stop: "stop"
        case .refresh: "arrow.clockwise"
        case .filter: "line.3.horizontal.decrease"
        case .minus: "minus"
        case .star: "star"
        case .key: "key"
        case .faceID: "faceid"
        case .scan: "viewfinder"
        case .image: "photo"
        case .play: "play"
        case .pause: "pause"
        case .wind: "wind"
        case .list: "list.bullet"
        case .globe: "globe"
        case .gift: "gift"
        case .arrowRight: "arrow.right"
        case .more: "ellipsis"
        case .percent: "percent"
        case .send: "paperplane"
        }
    }
}
