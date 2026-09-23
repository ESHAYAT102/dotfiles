This project includes [omapager](https://github.com/njpatel/omapager) by Neil Patel,
revision `f0ccd49ad7a57ec5c5615354c4fd3ef27df01363`, under Apache-2.0
(see LICENSE.omapager).

Imported files: Service.qml, Toast.qml, DeedButton.qml, Layout.js, Markup.js,
Detect.js, Store.js, and bin/omapager-{store,icon,kdeconnect}.

Changes: Service.qml adds a bounded notification-center model, history loading,
center dismissal/clearing, and pauses popup expiry while the center is open.
Incoming popups appear during hover; only inline reply defers arrivals.
bin/omapager-store adds deletion of individual history entries and clearing live/history together.
Toast.qml and its supporting renderer files are unchanged from upstream.
The original notification-center code remains under LICENSE (MIT).
