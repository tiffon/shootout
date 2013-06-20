
var factor = +arguments[0],
    l,
    i = 0,
    fullLen = 60,
    count = 0,
    PRINT = function(){};

if (arguments[0] === 'validate' || arguments[1] === 'validate') {
    PRINT = print;
    print = function(){};
}

factor = isNaN(factor) ? 150 : factor;

while (l = readline()) {
    if (l[0] !== '>' && l.length === fullLen) {
        i = 0;
        while (i++ < factor) {
            count++;
            print(l);
        }
    } else {
        print(l);
    }
}

PRINT('total: ' + count);
