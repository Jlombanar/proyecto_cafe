import mongoose from "mongoose"
const productShema =new mongoose.Schema({
    productId:{type:String,required:true,unique:true},
    Nombre:{type:String,required:true},
    Descripcion:{type:String,required:true},
    Precio:{type:Number,required:true},
    Image:{type:String,required:true},
});
//forzamos para que me guarde la informacion en la coleccion de Productos
const Product=mongoose.model("Productos",productShema,"Productos")

export default Product;