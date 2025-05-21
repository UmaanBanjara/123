const {Pool} = require('pg');
const pool = new Pool({
	user : 'feed_user',
	host : 'localhost',
	database : 'feed',
	password : 'thankyou',
	port : 5432 ,
});

module.exports = pool ; 
