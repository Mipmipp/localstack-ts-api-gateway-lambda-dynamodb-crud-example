import { ItemDTO, ItemModel } from "../models";
import { ErrorMessages } from "../utils";

class ItemService {
  async create(itemData: ItemDTO) {
    return await ItemModel.create(itemData);
  }

  async get(itemId: string) {
    const item = await ItemModel.get(itemId);
    return item || null;
  }

  async getAll() {
    return await ItemModel.scan().exec();
  }

  async update(itemId: string, itemData: ItemDTO) {
    if (!itemData.name) {
      throw new Error(ErrorMessages.INVALID_DATA);
    }
    return await ItemModel.update(itemId, itemData);
  }

  async delete(itemId: string) {
    return await ItemModel.delete(itemId);
  }
}

export default ItemService;
