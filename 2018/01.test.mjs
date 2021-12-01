/* global describe, expect, it */

import jest from "jest";
import {solve} from "./01";

console.log("Testing!", jest);
describe("day 1", () => {
  describe(solve, () => {
    it("is a function", () => {
      expect(typeof solve).toEqual("string");
    });
    it("accepts input as a string", () => {
      expect(() => solve("foo")).not.toThrow();
    });
  });
});
