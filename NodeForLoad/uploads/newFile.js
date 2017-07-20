var fs = require('fs');
function copy(des, scr){
  fs.stat(scr, function(err, stat){
    if (err) {
      console.log(err);
    }else {
      console.log('isFile: ' + stat.isFile);
      fs.writeFileSync(des, fs.readFileSync(scr));
      console.log('readFileSync');
    }
  })
}
var para = 'long long ago';
module.exports = {copy:copy,
                  para:para
                  }
