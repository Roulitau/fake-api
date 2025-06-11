const express = require("express");
const path = require("path");
const userRoute = require("./route/user.route");
const productRoute = require("./route/product.route");
const app = express();

app.use(express.json());

app.use((req, res, next) => {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Headers", 'Origin, X-Requested-With, Content, Accept, Content-Type, Authorization');
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    next();
});

app.use('/images', express.static(path.join(__dirname, "images")));

app.use('/user', userRoute);
app.use('/product', productRoute);

module.exports = app;

/*dsdqd*/
