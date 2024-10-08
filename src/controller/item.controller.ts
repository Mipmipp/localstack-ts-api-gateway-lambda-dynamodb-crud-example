import { APIGatewayEvent } from "aws-lambda";
import { StatusCodes } from "http-status-codes";
import { createResponse, ErrorMessages } from "../utils";
import { ItemService } from "../services";

const itemService = new ItemService();

const createItem = async (event: APIGatewayEvent) => {
  const itemData = JSON.parse(event.body ?? "{}");

  try {
    const newItem = await itemService.create(itemData);
    return createResponse(StatusCodes.CREATED, newItem);
  } catch (error) {
    return createResponse(StatusCodes.BAD_REQUEST, {
      message: ErrorMessages.INVALID_DATA,
    });
  }
};

const getItem = async (event: APIGatewayEvent) => {
  const itemId = event.pathParameters?.itemId;

  if (!itemId) {
    return createResponse(StatusCodes.BAD_REQUEST, {
      message: ErrorMessages.ITEM_ID_REQUIRED,
    });
  }

  try {
    const item = await itemService.get(itemId);

    if (!item) {
      return createResponse(StatusCodes.NOT_FOUND, {
        message: ErrorMessages.ITEM_NOT_FOUND,
      });
    }

    return createResponse(StatusCodes.OK, item);
  } catch (error) {
    return createResponse(StatusCodes.NOT_FOUND, {
      message: ErrorMessages.INTERNAL_SERVER_ERROR,
    });
  }
};

const getAllItems = async () => {
  console.log("getAllItems controller");
  const items = await itemService.getAll();
  console.log("items", items);
  try {
    return createResponse(StatusCodes.OK, items);
  } catch (error) {
    return createResponse(StatusCodes.INTERNAL_SERVER_ERROR, {
      message: ErrorMessages.INTERNAL_SERVER_ERROR,
    });
  }
};

const updateItem = async (event: APIGatewayEvent) => {
  const itemId = event.pathParameters?.itemId;

  if (!itemId) {
    return createResponse(StatusCodes.BAD_REQUEST, {
      message: ErrorMessages.ITEM_ID_REQUIRED,
    });
  }

  const existingItem = await itemService.get(itemId);

  if (!existingItem) {
    return createResponse(StatusCodes.NOT_FOUND, {
      message: ErrorMessages.ITEM_NOT_FOUND,
    });
  }

  const itemData = JSON.parse(event.body ?? "{}");

  try {
    const updatedItem = await itemService.update(itemId, itemData);
    return createResponse(StatusCodes.OK, updatedItem);
  } catch (error) {
    return createResponse(StatusCodes.BAD_REQUEST, {
      message: ErrorMessages.INVALID_DATA,
    });
  }
};

const deleteItem = async (event: APIGatewayEvent) => {
  const itemId = event.pathParameters?.itemId;

  if (!itemId) {
    return createResponse(StatusCodes.BAD_REQUEST, {
      message: ErrorMessages.ITEM_ID_REQUIRED,
    });
  }

  const existingItem = await itemService.get(itemId);

  if (!existingItem) {
    return createResponse(StatusCodes.NOT_FOUND, {
      message: ErrorMessages.ITEM_NOT_FOUND,
    });
  }

  try {
    await itemService.delete(itemId);
    return createResponse(StatusCodes.OK, existingItem);
  } catch (error) {
    return createResponse(StatusCodes.INTERNAL_SERVER_ERROR, {
      message: ErrorMessages.INTERNAL_SERVER_ERROR,
    });
  }
};

export { createItem, getItem, getAllItems, updateItem, deleteItem };
