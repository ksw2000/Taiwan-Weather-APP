// node get-station-data.js

const https = require('https');
const fs = require('fs');

https.get('https://opendata.cwb.gov.tw/api/v1/rest/datastore/O-A0003-001?Authorization=CWB-4265762E-BC4C-49FE-901B-EABE576583F6', (res) => {
  const { statusCode } = res;
  const contentType = res.headers['content-type'];

  let error;
  // Any 2xx status code signals a successful response but
  // here we're only checking for 200.
  if (statusCode !== 200) {
    error = new Error('Request Failed.\n' +
                      `Status Code: ${statusCode}`);
  } else if (!/^application\/json/.test(contentType)) {
    error = new Error('Invalid content-type.\n' +
                      `Expected application/json but received ${contentType}`);
  }
  if (error) {
    console.error(error.message);
    // Consume response data to free up memory
    res.resume();
    return;
  }

  res.setEncoding('utf8');
  let rawData = '';
  res.on('data', (chunk) => { rawData += chunk; });
  res.on('end', () => {
    try {
      const data = JSON.parse(rawData);
      /*------------------------------------------------------------------------*/
      let len = data["records"]["location"].length;
      let ret = [];
      for(let i=0; i<len; i++){
          let tmp = {};
          tmp["lat"] = data["records"]["location"][i]["lat"];
          tmp["lon"] = data["records"]["location"][i]["lon"];
          tmp["locationName"] = data["records"]["location"][i]["locationName"];
          ret.push(tmp);
      }
      /*------------------------------------------------------------------------*/

      fs.writeFile("lib/station.json", JSON.stringify(ret, null, "\t"), 'utf8', ()=>{
          console.log("done!");
      })
    } catch (e) {
      console.error(e.message);
    }
  });
}).on('error', (e) => {
  console.error(`Got error: ${e.message}`);
});
