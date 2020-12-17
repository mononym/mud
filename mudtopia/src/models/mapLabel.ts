export interface MapLabelInterface {
    id: string;
    x: number;
    y: number;
    text: string
    rotation: number
    color: string
    size: number
    inlineSize: number
    style: string
    weight: string
    family: string
  }

  const state: MapLabelInterface = {
    id: '',
    x: 0,
    y: 0,
    text: '',
    rotation: 0,
    color: '',
    size: 20,
    inlineSize: 200,
    style: 'normal',
    weight: 'normal',
    family: 'sans-sarif'
  }

export default state;