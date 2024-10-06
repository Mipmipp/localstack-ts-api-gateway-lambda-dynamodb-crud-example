import { APIGatewayEvent } from "aws-lambda";
import { StatusCodes } from "http-status-codes";
import { createResponse, ErrorMessages } from "../utils";
import { ItemService } from "../services";

const itemService = new ItemService();

const createItem = async (event: APIGatewayEvent) => {
  const itemData = JSON.parse(event.body ?? "{}");
  const newItem = await itemService.create(itemData);

  return createResponse(StatusCodes.CREATED, newItem);
};

const getItem = async (event: APIGatewayEvent) => {
  const itemId = event.pathParameters?.id;

  if (!itemId) {
    return createResponse(StatusCodes.BAD_REQUEST, {
      message: ErrorMessages.ITEM_ID_REQUIRED,
    });
  }

  const item = await itemService.get(itemId);

  return createResponse(StatusCodes.OK, item);
};

const getAllItems = async () => {
  const items = await itemService.getAll();

  return createResponse(StatusCodes.OK, items);
};

const updateItem = async (event: APIGatewayEvent) => {
  const itemId = event.pathParameters?.id;

  if (!itemId) {
    return createResponse(StatusCodes.BAD_REQUEST, {
      message: ErrorMessages.ITEM_ID_REQUIRED,
    });
  }

  const itemData = JSON.parse(event.body ?? "{}");
  const updatedItem = await itemService.update(itemId, itemData);

  return createResponse(StatusCodes.OK, updatedItem);
};

const deleteItem = async (event: APIGatewayEvent) => {
  const itemId = event.pathParameters?.id;

  if (!itemId) {
    return createResponse(StatusCodes.BAD_REQUEST, {
      message: ErrorMessages.ITEM_ID_REQUIRED,
    });
  }

  const itemDeleted = await itemService.get(itemId);
  await itemService.delete(itemId);

  return createResponse(StatusCodes.NO_CONTENT, itemDeleted);
};

export { createItem, getItem, getAllItems, updateItem, deleteItem };
