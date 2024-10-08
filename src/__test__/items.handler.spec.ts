import { describe, it, expect, jest, beforeEach } from "@jest/globals";
import { handler } from "..";

jest.mock("../models/item.model", () => {
  return {
    __esModule: true,
    default: {
      create: jest.fn((data: any) => {
        if (!data.name) {
          return Promise.reject(new Error("Invalid data provided."));
        }
        return Promise.resolve({
          ...data,
          id: "1",
          createdAt: new Date().toISOString(),
        });
      }),
      get: jest.fn((id) => {
        if (id === "1") {
          return Promise.resolve({
            id: "1",
            name: "Item 1",
            description: "A test item",
            createdAt: new Date().toISOString(),
          });
        }
        return Promise.resolve(null);
      }),
      scan: jest.fn().mockReturnValue({
        exec: jest
          .fn()
          .mockReturnValueOnce(Promise.resolve([{ id: "1", name: "Item 1" }])),
      }),
      update: jest.fn((id, data: any) => {
        if (id === "1") {
          return Promise.resolve({
            ...data,
            id: "1",
            createdAt: new Date().toISOString(),
          });
        }
        return Promise.reject(new Error("Item not found."));
      }),
      delete: jest.fn((id) => {
        if (id === "1") {
          return Promise.resolve({
            id: "1",
            name: "Item 1",
            description: "A test item",
            createdAt: new Date().toISOString(),
          });
        }
        return Promise.reject(new Error("Item not found."));
      }),
    },
  };
});

describe("API Handler", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("Get all items - [GET /items]", () => {
    it("should call getAllItems on GET without itemId", async () => {
      const event = {
        httpMethod: "GET",
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(200);
      expect(JSON.parse(result.body)).toEqual([{ id: "1", name: "Item 1" }]);
    });
  });

  describe("Get item by ID - [GET /items/{itemId}]", () => {
    it("should return an item", async () => {
      const event = {
        httpMethod: "GET",
        pathParameters: {
          itemId: "1",
        },
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(200);
      expect(JSON.parse(result.body)).toEqual(
        expect.objectContaining({
          id: "1",
          name: expect.any(String),
          description: expect.any(String),
          createdAt: expect.any(String),
        })
      );
    });

    it("should return 404 if item not found", async () => {
      const event = {
        httpMethod: "GET",
        pathParameters: {
          itemId: "100",
        },
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(404);
      expect(JSON.parse(result.body)).toEqual({
        message: "Item not found.",
      });
    });
  });

  describe("Create item - [POST /items]", () => {
    it("should create an item", async () => {
      const PostDTO = {
        name: "test-post-name",
        description: "test-post-description",
      };

      const event = {
        httpMethod: "POST",
        body: JSON.stringify(PostDTO),
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(201);
      expect(JSON.parse(result.body)).toEqual(
        expect.objectContaining({
          name: PostDTO.name,
          description: PostDTO.description,
          createdAt: expect.any(String),
          id: expect.any(String),
        })
      );
    });

    it("should create an item without description", async () => {
      const PostDTO = {
        name: "test-post-name",
      };

      const event = {
        httpMethod: "POST",
        body: JSON.stringify(PostDTO),
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(201);
      expect(JSON.parse(result.body)).toEqual(
        expect.objectContaining({
          name: PostDTO.name,
          createdAt: expect.any(String),
          id: expect.any(String),
        })
      );
    });

    it("should return error if invalid data provided", async () => {
      const PostDTO = {
        tier: "premium",
      };

      const event = {
        httpMethod: "POST",
        body: JSON.stringify(PostDTO),
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(400);
      expect(JSON.parse(result.body)).toEqual({
        message: "Invalid data provided.",
      });
    });
  });

  describe("Update item - [PUT /items/{itemId}]", () => {
    it("should update an item", async () => {
      const PutDTO = {
        name: "test-put-name",
        description: "test-put-description",
      };

      const event = {
        httpMethod: "PUT",
        pathParameters: {
          itemId: "1",
        },
        body: JSON.stringify(PutDTO),
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(200);
      expect(JSON.parse(result.body)).toEqual(
        expect.objectContaining({
          name: PutDTO.name,
          description: PutDTO.description,
          createdAt: expect.any(String),
          id: "1",
        })
      );
    });

    it("should return error if invalid data provided", async () => {
      const PutDTO = {
        tier: "premium",
      };

      const event = {
        httpMethod: "PUT",
        pathParameters: {
          itemId: "1",
        },
        body: JSON.stringify(PutDTO),
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(400);
      expect(JSON.parse(result.body)).toEqual({
        message: "Invalid data provided.",
      });
    });

    it("should return 404 if item not found", async () => {
      const PutDTO = {
        name: "test-put-name",
        description: "test-put-description",
      };

      const event = {
        httpMethod: "PUT",
        pathParameters: {
          itemId: "100",
        },
        body: JSON.stringify(PutDTO),
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(404);
      expect(JSON.parse(result.body)).toEqual({
        message: "Item not found.",
      });
    });
  });

  describe("Delete item - [DELETE /items/{itemId}]", () => {
    it("should delete an item", async () => {
      const event = {
        httpMethod: "DELETE",
        pathParameters: {
          itemId: "1",
        },
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(200);
      expect(JSON.parse(result.body)).toEqual(
        expect.objectContaining({
          name: expect.any(String),
          description: expect.any(String),
          createdAt: expect.any(String),
          id: "1",
        })
      );
    });

    it("should return 404 if item not found", async () => {
      const event = {
        httpMethod: "DELETE",
        pathParameters: {
          itemId: "100",
        },
      };

      const result = await handler(event as any);

      expect(result.statusCode).toBe(404);
      expect(JSON.parse(result.body)).toEqual({
        message: "Item not found.",
      });
    });
  });
});
