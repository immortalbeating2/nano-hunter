import { describe, expect, it } from "vitest";
import {
  DEFAULT_LEGACY_RESERVED_CLI_PORTS,
  DEFAULT_LEGACY_STDIO_PORTS,
  DEFAULT_RESERVED_CLI_PORTS,
  DEFAULT_STDIO_PORTS,
  buildCandidatePorts,
  normalizeWorkspacePath,
  parsePortList,
} from "../src/godot-connection.js";

describe("Godot MCP stdio port plan", () => {
  it("uses 17605-17619 for stdio and keeps CLI ranges reserved", () => {
    const ports = buildCandidatePorts();

    expect(DEFAULT_STDIO_PORTS).toEqual([
      17605, 17606, 17607, 17608, 17609,
      17610, 17611, 17612, 17613, 17614,
      17615, 17616, 17617, 17618, 17619,
    ]);
    expect(DEFAULT_RESERVED_CLI_PORTS).toEqual([17620, 17621, 17622, 17623, 17624]);
    expect(DEFAULT_LEGACY_STDIO_PORTS).toEqual([6505, 6506, 6507, 6508, 6509]);
    expect(DEFAULT_LEGACY_RESERVED_CLI_PORTS).toEqual([6510, 6511, 6512, 6513, 6514]);
    expect(ports.slice(0, 5)).toEqual([17605, 17606, 17607, 17608, 17609]);
    expect(ports.slice(-5)).toEqual([6505, 6506, 6507, 6508, 6509]);
    expect(ports).not.toContain(17620);
    expect(ports).not.toContain(17624);
    expect(ports).not.toContain(6510);
    expect(ports).not.toContain(6514);
  });

  it("parses reserved port ranges and individual ports", () => {
    expect(parsePortList("17620-17622,6505")).toEqual([6505, 17620, 17621, 17622]);
  });

  it("normalizes workspace paths for Godot and Node comparisons", () => {
    expect(normalizeWorkspacePath("C:\\Users\\peng8\\Project\\nano-hunter\\")).toBe(
      "c:/users/peng8/project/nano-hunter"
    );
  });
});
