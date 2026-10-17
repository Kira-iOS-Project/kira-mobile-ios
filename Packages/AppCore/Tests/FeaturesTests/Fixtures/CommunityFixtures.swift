/** The community routes' answers, as the backend sends them (Komunitas and Detail Grup boards). */

let groupSummaryJSON = #"""
    {"id":"6f1c2a9e-0000-4000-8000-000000000001","name":"Lunas Bareng Jakarta","category":"debt_free",\#
    "platform":"whatsapp","memberCount":1240,"summary":"Saling dukung melunasi utang lewat jalur resmi.",\#
    "icon":"paylater","educationOnly":false}
    """#

let communityGroupsJSON = #"""
    {"categories":[{"key":"debt_free","label":"Bebas Hutang"},{"key":"crypto","label":"Web3/Kripto"}],\#
    "groups":[\#(groupSummaryJSON),{"id":"6f1c2a9e-0000-4000-8000-000000000003","name":"Kripto Aman 101",\#
    "category":"crypto","platform":"discord","memberCount":2050,"summary":"Kenali risiko.","icon":"bintang",\#
    "educationOnly":true}]}
    """#

let communityGroupJSON = #"""
    {"id":"6f1c2a9e-0000-4000-8000-000000000001","name":"Lunas Bareng Jakarta","category":"debt_free",\#
    "platform":"whatsapp","memberCount":1240,"summary":"Saling dukung.","icon":"paylater","educationOnly":false,\#
    "about":"Saling dukung melunasi utang lewat jalur resmi.","admin":{"name":"Rani A.","initials":"RA",\#
    "verifiedSince":"2026-03"},"rules":["Tanpa Ajakan Gagal Bayar","Tanpa Jual-Beli Data atau Joki",\#
    "Jaga Privasi Sesama Anggota"],"linkCheckedOn":"2026-10-12","adminUnchanged":true,"rulesAccepted":false}
    """#

let communityJoinJSON = #"""
    {"inviteUrl":"https://chat.whatsapp.com/LunasBarengJakarta","platform":"whatsapp","linkCheckedOn":"2026-10-12"}
    """#
