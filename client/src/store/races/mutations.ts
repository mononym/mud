import { MutationTree } from 'vuex';
import { RaceInterface, RacesInterface } from './state';
import Vue from 'vue';

const mutation: MutationTree<RacesInterface> = {
    putRaces(state: RacesInterface, races: RacesInterface[]) {
      Vue.set(state, 'races',
      races.reduce(
        (map: Map<string, RaceInterface>, race: RaceInterface) => (
          (map.set(race.singular, race)), map
        ),
        new Map()
      ))
    }};

export default mutation;
