const express = require('express');
const app = express();


// Start the server
const port = process.env.PORT || 3000; //PORT from environment or default to 3000
app.listen(port, () => {
    console.log(`App running on port ${port}`);
});
