import request from "supertest";
import dotenv from "dotenv";
import { describe, it, expect } from "@jest/globals";
import { StatusCodes } from "http-status-codes";

dotenv.config({ path: ".local.env" });

const BASE_ENDPOINT = `http://127.0.0.1:4566/restapis/${process.env.LOCAL_API_ID}/test/_user_request_`;

describe("Get all items - [GET /items]", () => {
  it("Should return all items", async () => {
    return request(BASE_ENDPOINT)
      .get("/items")
      .expect(StatusCodes.OK)
      .then(({ body }) => {
        expect(body).toEqual(
          expect.arrayContaining([
            {
              name: expect.any(String),
              description: expect.any(String),
              createdAt: expect.any(String),
              id: expect.any(String),
            },
            {
              name: expect.any(String),
              description: expect.any(String),
              createdAt: expect.any(String),
              id: expect.any(String),
            },
          ])
        );
      });
  });
});

describe("Get item by ID - [GET /items/{itemId}]", () => {
  it("Should return an item", async () => {
    return request(BASE_ENDPOINT)
      .get("/items/1")
      .expect(StatusCodes.OK)
      .then(({ body }) => {
        expect(body).toEqual(
          expect.objectContaining({
            name: expect.any(String),
            description: expect.any(String),
            createdAt: expect.any(String),
            id: "1",
          })
        );
      });
  });

  it("Should return 404 if item not found", async () => {
    return request(BASE_ENDPOINT)
      .get("/items/100")
      .expect(StatusCodes.NOT_FOUND)
      .then(({ body }) =>
        expect(body).toEqual({
          message: "Item not found.",
        })
      );
  });
});

describe("Create item - [POST /items]", () => {
  it("Should create an item", async () => {
    const PostDTO = {
      name: "test-post-name",
      description: "test-post-description",
    };

    return request(BASE_ENDPOINT)
      .post("/items")
      .send(PostDTO)
      .expect(StatusCodes.CREATED)
      .then(({ body }) => {
        expect(body).toEqual(
          expect.objectContaining({
            name: PostDTO.name,
            description: PostDTO.description,
            createdAt: expect.any(String),
            id: expect.any(String),
          })
        );
      });
  });

  it("Should create an item without description", async () => {
    const PostDTO = {
      name: "test-post-name",
    };

    return request(BASE_ENDPOINT)
      .post("/items")
      .send(PostDTO)
      .expect(StatusCodes.CREATED)
      .then(({ body }) => {
        expect(body).toEqual(
          expect.objectContaining({
            name: PostDTO.name,
            createdAt: expect.any(String),
            id: expect.any(String),
          })
        );
      });
  });

  it("Should return error if invalid data provided", async () => {
    const PostDTO = {
      tier: "premium",
    };

    return request(BASE_ENDPOINT)
      .post("/items")
      .send(PostDTO)
      .expect(StatusCodes.BAD_REQUEST)
      .then(({ body }) => {
        expect(body).toEqual({
          message: "Invalid data provided.",
        });
      });
  });
});

describe("Update item - [PUT /items/{itemId}]", () => {
  it("Should update an item", async () => {
    const PutDTO = {
      name: "test-put-name",
      description: "test-put-description",
    };

    return request(BASE_ENDPOINT)
      .put("/items/1")
      .send(PutDTO)
      .expect(StatusCodes.OK)
      .then(({ body }) => {
        expect(body).toEqual(
          expect.objectContaining({
            name: PutDTO.name,
            description: PutDTO.description,
            createdAt: expect.any(String),
            id: "1",
          })
        );
      });
  });

  it("Should return error if invalid data provided", async () => {
    const PutDTO = {
      tier: "premium",
    };

    return request(BASE_ENDPOINT)
      .put("/items/1")
      .send(PutDTO)
      .expect(StatusCodes.BAD_REQUEST)
      .then(({ body }) => {
        expect(body).toEqual({
          message: "Invalid data provided.",
        });
      });
  });

  it("Should return 404 if item not found", async () => {
    const PutDTO = {
      name: "test-put-name",
      description: "test-put-description",
    };

    return request(BASE_ENDPOINT)
      .put("/items/100")
      .send(PutDTO)
      .expect(StatusCodes.NOT_FOUND)
      .then(({ body }) =>
        expect(body).toEqual({
          message: "Item not found.",
        })
      );
  });
});

describe("Delete item - [DELETE /items/{itemId}]", () => {
  it("Should delete an item", async () => {
    return request(BASE_ENDPOINT)
      .delete("/items/1")
      .expect(StatusCodes.OK)
      .then(({ body }) => {
        expect(body).toEqual(
          expect.objectContaining({
            name: expect.any(String),
            description: expect.any(String),
            createdAt: expect.any(String),
            id: "1",
          })
        );
      });
  });

  it("Should return 404 if item not found", async () => {
    return request(BASE_ENDPOINT)
      .delete("/items/100")
      .expect(StatusCodes.NOT_FOUND)
      .then(({ body }) =>
        expect(body).toEqual({
          message: "Item not found.",
        })
      );
  });
});
