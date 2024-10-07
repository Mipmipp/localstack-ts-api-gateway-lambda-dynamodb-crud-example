import dynamoose from "dynamoose";
import { itemSchema } from "../schemas";

const ddb = new dynamoose.aws.ddb.DynamoDB({
  endpoint: process.env.DYNAMO_ENDPOINT,
  region: process.env.DYNAMO_REGION,
});

dynamoose.aws.ddb.set(ddb);

const ItemModel = dynamoose.model("items", itemSchema);

export default ItemModel;
