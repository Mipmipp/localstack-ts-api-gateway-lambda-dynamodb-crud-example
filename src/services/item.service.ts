import { ItemDTO, ItemModel } from "../models";
import { ErrorMessages } from "../utils";

class ItemService {
  async create(itemData: ItemDTO) {
    return await ItemModel.create(itemData);
  }

  async get(itemId: string) {
    const item = await ItemModel.get(itemId);

    if (!item) {
      throw new Error(ErrorMessages.ITEM_NOT_FOUND);
    }

    return item;
  }

  async getAll() {
    return await ItemModel.scan().exec();
  }

  async update(itemId: string, itemData: ItemDTO) {
    const updatedItem = await ItemModel.update(itemId, itemData);

    if (!updatedItem) {
      throw new Error(ErrorMessages.ITEM_NOT_FOUND);
    }

    return updatedItem;
  }

  async delete(itemId: string) {
    const item = await this.get(itemId);
    await ItemModel.delete(itemId);

    return item;
  }
}

export default ItemService;
