const {setGlobalOptions} = require("firebase-functions/v2");
const admin = require("firebase-admin");

// const { startShipment } = require("./api");
setGlobalOptions({maxInstances: 10});
admin.initializeApp();
exports.startShipment = require("./controllers/start_shipment").startShipment;
exports.inviteUser = require("./controllers/invite_user").inviteUser;
exports.refundOrder = require("./controllers/refund_order").refundOrder;
exports.sendRefundNotification =
require("./controllers/send_refund_notification").sendRefundNotification;
