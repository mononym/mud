<template>
  <q-page class="flex flex-center">
    <div class="row landing-page-row">
      <div class="col">
        <div class="col landing-page-content-column">
          <h1>
            Whether it's your first time, or you're an old hand, all you need is your email address to get started.
          </h1>
        </div>
        <div class="col landing-page-content-column">
          <email-auth-form></email-auth-form>
        </div>
      </div>
    </div>
  </q-page>
</template>

<style>
</style>

<script>
import { openURL } from 'quasar'
import EmailAuthForm from '../components/EmailAuthForm.vue'

export default {
  name: 'LandingPage',
  components: { 'email-auth-form': EmailAuthForm },
  methods: {
    openURL
  }
}
</script>
