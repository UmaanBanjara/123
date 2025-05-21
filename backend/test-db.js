const pool = require('./db') ;

async function testQuery(){
	try{
		const res = await pool.query('SELECT * FROM users;');
		console.log('Users:',res.rows);
		}
	catch(err){
	console.error('Error running query',err);
	}
	finally {
	pool.end();
	}}

testQuery();
