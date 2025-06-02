const jwt = require('jsonwebtoken');

//middleware to authenticate the toknen 

function authenticatetoken(req , res , next){
	//get the authorization header value 


	const authHeader = req.headers['authorization'];

	//tokoen usually sent as bearer<token>

	//if autheheader exits , split garr ani token part le
	const token = authHeader && authHeader.split(' ')[1];

	if(!token){

		return res.status(401).json({error : 'Access denied. No token provided'});
	}


	//verify the token

	jwt.verify(token , process.env.JWT_SECRET , (err , user) => {
		if(err){
			return res.status(403).json({error : 'Invalid token'});
		}

		req.user = user ;

		//call the next middleware or route handle

		next();
	});
}

module.exports = authenticatetoken;