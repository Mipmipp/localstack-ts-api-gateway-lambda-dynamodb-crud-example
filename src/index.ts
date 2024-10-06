import { APIGatewayEvent, APIGatewayProxyResult } from "aws-lambda";
import { StatusCodes } from "http-status-codes";
import {
  createItem,
  deleteItem,
  getAllItems,
  getItem,
  updateItem,
} from "./controller";
import { ErrorMessages } from "./utils";

export const handler = async (
  event: APIGatewayEvent
): Promise<APIGatewayProxyResult> => {
  switch (event.httpMethod) {
    case "POST":
      return createItem(event);
    case "GET":
      if (event.pathParameters) {
        return getItem(event);
      }
      return getAllItems();
    case "PUT":
      return updateItem(event);
    case "DELETE":
      return deleteItem(event);
    default:
      return {
        statusCode: StatusCodes.METHOD_NOT_ALLOWED,
        body: JSON.stringify({ message: ErrorMessages.METHOD_NOT_ALLOWED }),
      };
  }
};
