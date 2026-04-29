import { describe, expect, it } from "vitest";
import {
  DEFAULT_RESERVED_CLI_PORTS,
  buildCandidatePorts,
  normalizeWorkspacePath,
  parsePortList,
} from "../src/godot-connection.js";

describe("Godot MCP stdio port plan", () => {
  it("keeps CLI ports reserved while extending stdio bridge ports", () => {
    const ports = buildCandidatePorts();

    expect(ports.slice(0, 5)).toEqual([6505, 6506, 6507, 6508, 6509]);
    expect(DEFAULT_RESERVED_CLI_PORTS).toEqual([6510, 6511, 6512, 6513, 6514]);
    expect(ports).not.toContain(6510);
    expect(ports).not.toContain(6514);
    expect(ports.slice(-3)).toEqual([6532, 6533, 6534]);
  });

  it("parses reserved port ranges and individual ports", () => {
    expect(parsePortList("6510-6512,6520")).toEqual([6510, 6511, 6512, 6520]);
  });

  it("normalizes workspace paths for Godot and Node comparisons", () => {
    expect(normalizeWorkspacePath("C:\\Users\\peng8\\Project\\nano-hunter\\")).toBe(
      "c:/users/peng8/project/nano-hunter"
    );
  });
});
