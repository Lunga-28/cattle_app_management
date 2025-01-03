import express from 'express';
const { signin, signup, google} = require ('../controller/auth.controller.js');

const router = express.Router();


router.post('/signup', signup);
router.post('/signin', signin);
router.post('/google', google);

module.exports = router;