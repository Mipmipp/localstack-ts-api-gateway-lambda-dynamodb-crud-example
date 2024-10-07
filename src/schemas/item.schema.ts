import dynamoose from "dynamoose";
import { v4 as uuidv4 } from "uuid";

const itemSchema = new dynamoose.Schema({
  id: {
    type: String,
    hashKey: true,
    default: () => uuidv4(),
  },
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: false,
  },
  createdAt: {
    type: String,
    default: () => new Date().toISOString(),
  },
});

export default itemSchema;
