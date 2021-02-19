export interface MapLabelInterface {
  id: string;
  x: number;
  y: number;
  text: string;
  rotation: number;
  color: string;
  size: number;
  style: string;
  weight: string;
  family: string;
  vertical_offset: number;
  horizontal_offset: number;
}

const state: MapLabelInterface = {
  id: "",
  x: 0,
  y: 0,
  text: "",
  rotation: 0,
  color: "#FFFFFF",
  size: 20,
  style: "normal",
  weight: "normal",
  family: "sans-sarif",
  vertical_offset: 0,
  horizontal_offset: 0,
};

export default state;
