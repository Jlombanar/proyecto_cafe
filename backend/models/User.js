import mongoose from "mongoose";
import bcrypt from "bcryptjs";


const userSchema = new mongoose.Schema({

  Nombre: { type: String, required: true, uppercase: true, trim: true },
  Apellido: { type: String, required: true, uppercase: true, trim: true },
  telefono: { type: String, required: true, trim: true },
  Correo_Electronico: { type: String, required: true, unique: true, lowercase: true, trim: true },
  passwords: { type: String, required: true },

  // contraaseña de google
   passwords: { type: String },
    googleId: { type: String, unique: true, sparse: true },
    avatar: { type: String, default: "" },

  // Verificación de cuenta
  isVerified: { type: Boolean, default: false },
  codigoVerificacion: { type: String },
  codigoVerificacionExpiracion: { type: Date },
  // Recuperación de contraseña
  codigoRecuperacion: String,
  codigoexpiracion: Date,
  rol: { type: String, enum: ["admin","usuario"], default: "usuario" }
}, { timestamps: true });

// 2. ENCRIPTAR LA CONTRASEÑA ANTES DE GUARDAR

userSchema.pre("save", async function () {
  // Solo encriptamos si la contraseña fue creada o modificada
  if (!this.isModified("passwords")) return; 

  const salt = await bcrypt.genSalt(10);
  this.passwords = await bcrypt.hash(this.passwords, salt);
  
});

// 3. FINALMENTE CREAR EL MODELO
const User = mongoose.model("User", userSchema);

export default User;