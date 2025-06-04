const axios = require('axios');
const express = require('express');
const router = express.Router();


const TENOR_API_KEY = process.env.TENOR_API_KEY;

router.get('/' , async(req , res)=>{


    const query = req.query.q;


    try{
        const response = await axios.get(
            'https://tenor.googleapis.com/v2/search',

            {
                params : {
                    q : query , 
                    key: process.env.TENOR_API_KEY,
                    limit : 20,
                }
            }
        );

        res.json(response.data);


    }
    catch (error){
        console.error('Error Fetching GIFS' , error.message);
        res.status(500).json({error : 'Failed to fetch GIFS'});
    }



});

module.exports = router;