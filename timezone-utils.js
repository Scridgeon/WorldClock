// Import moment.js and moment-timezone from the same plugin directory
.import "moment.js" as MomentJS
.import "moment-timezone.js" as MomentTimezone

function getTimeInTimezone(timezone, format) {
    var displayFormat = format ? format : "HH:mm";
    
    try {
        // Check if moment is available in global scope
        var m = (typeof MomentJS !== 'undefined' && MomentJS.moment) ? MomentJS.moment : 
                (typeof moment !== 'undefined') ? moment : null;

        if (!m) return "No Moment";

        // Check if the tz function exists
        if (typeof m.tz !== 'function') {
             return m().format(displayFormat); 
        }

        return m.tz(timezone).format(displayFormat);
        
    } catch (e) {
        return "Format Error";
    }
}

function isMomentAvailable() {
    return (typeof MomentJS !== 'undefined' && MomentJS.moment);
}
