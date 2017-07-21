var fs = require('fs');

exports.index = function(req,res){
  res.setHeader('Content-Type','text/json; charset=UTF-8');
  fs.readdir('./uploads', function(error, files){
    if(error){
      res.status(500).send(error);
    }else{
      var resultArray = new Array();
      files.forEach(function(file){
        var obj = {
          "name":file
        };
        resultArray.push(obj);
      })
      var resultString = JSON.stringify(resultArray);
      res.status(200).send(resultString);
    }
  });
}
