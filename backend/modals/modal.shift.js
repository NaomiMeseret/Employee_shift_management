import mongoose from "mongoose";

const shiftSchema = new mongoose.Schema(
  {
    id: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    employeeId: {
      type: Number,
      required: true,
    },
    date: {
      type: String,
      required: true,
    },
    shiftType: {
      type: String,
      enum: ["morning", "afternoon", "night"],
      required: true,
    },
    attendance: [
      {
        actionType: {
          type: String,
          enum: ["Clock In", "Clock Out"],
        },
        time: {
          type: String,
        },
        date: {
          type: String,
        },
        status: {
          type: String,
          enum: ["active", "on leave", "inactive"],
        },
      },
    ],
  },
  { timestamps: true }
);

const Shift = mongoose.model("Shift", shiftSchema);
export default Shift;