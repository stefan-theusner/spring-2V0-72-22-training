function fn() {

    const ConcurrentHashMap = Java.type('java.util.concurrent.ConcurrentHashMap');
    globalThis.sharedStore = globalThis.sharedStore || new ConcurrentHashMap();

    const envFile = karate.env ? karate.env + '.yaml' : 'env.yaml';
    const config = karate.read('file:'+envFile);
    config.store = globalThis.sharedStore;

    const pick = function(arr) {
        return arr[Math.floor(Math.random() * arr.length)]
    }
    config.parseDuration = function(val) {
        if (typeof val === 'number') {
            return val * 1000;
        }
        var str = (val + '').trim().toLowerCase();
        var match = str.match(/^(\d+(?:\.\d+)?)\s*(ms|s|m|h)?$/);
        if (!match) {
            throw new Error('Invalid duration format: ' + val);
        }
        var num = parseFloat(match[1]);
        var unit = match[2] || 's';

        switch (unit) {
            case 'ms': return num;
            case 's':  return num * 1000;
            case 'm':  return num * 60 * 1000;
            case 'h':  return num * 60 * 60 * 1000;
            default:   return num * 1000;
        }
    };

    config.faker = {
        randomUuid: function() {
            return java.util.UUID.randomUUID() + '';
        },
        randomInt: function(min, max) {
            min = (min !== undefined) ? min : 1;
            max = (max !== undefined) ? max : 10000;
            return Math.floor(Math.random() * (max - min + 1)) + min;
        },
        randomDepartment: function() {
            return pick([
                'Engineering', 'Marketing', 'Sales', 'Finance', 'Human Resources', 'Legal', 'Support', 'Operations'
            ]);
        },
        randomStreetAddress: function() {
            var streets = [
                'Main St', 'Oak Ave', 'Park Blvd', 'Elm St', 'Cedar Ln', 'Maple Dr', 'Washington St'
            ];
            return config.faker.randomInt(10, 9999) + ' ' + pick(streets);
        },
    };

    return config;
}