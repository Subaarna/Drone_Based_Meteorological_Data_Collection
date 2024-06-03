const {ObjectId} = require('mongodb');

class User{
    constructor(email, password){
        this._id = new ObjectId();
        this.email = email;
        this.password = password;
    }
}
class UserLogin{
    constructor(email, password){
        this.email = email;
        this.password = password;
    }
}
module.exports = {User, UserLogin};