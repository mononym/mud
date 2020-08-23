<template>
  <div class="relative-position">
    <form-wrapper :validator="$v.form">
      <q-form class="q-gutter-md" ref="form">
        <q-input
          filled
          type="email"
          v-model="form.email"
          label="Email address *"
        >
          <q-tooltip content-style="font-size: 12px">
            Your email address is never displayed to anyone.
          </q-tooltip>
          <template v-slot:prepend>
            <q-icon name="mail" />
          </template>
          <template v-slot:append>
            <q-btn
              label="Login or Signup"
              type="submit"
              color="primary"
              :disabled="formIsDisabled"
              @click="submit"
            />
          </template>
        </q-input>
      </q-form>
    </form-wrapper>
    <q-inner-loading :showing="requestInProgress">
      <q-spinner-gears size="50px" color="primary" />
    </q-inner-loading>
  </div>
</template>

<script>
import { validationMixin } from 'vuelidate';
import {
  helpers,
  required,
  maxLength,
  minLength
} from 'vuelidate/lib/validators';
import { templates } from 'vuelidate-error-extractor';
import { actions } from 'src/store/auth/constants';

const emailRegex = helpers.regex('email', /^.+@.+$/);

export default {
  name: 'email-auth-form',
  mixins: [validationMixin],
  components: {
    FormWrapper: templates.FormWrapper
  },
  data() {
    return {
      form: {
        email: ''
      },
      submitStatus: 'WAITING'
    };
  },
  computed: {
    formIsDisabled() {
      return this.$v.$invalid;
    },
    requestInProgress() {
      return this.submitStatus === 'PENDING';
    }
  },
  validations: {
    form: {
      email: {
        required,
        minLength: minLength(3),
        maxLength: maxLength(254),
        emailRegex
      }
    }
  },
  methods: {
    submit() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR';
      } else {
        this.submitStatus = 'PENDING';
        
        this.$store.dispatch(actions.AUTH_START).then(() => {
          console.log('auth started')
          return this.$axios
            .post('/authenticate/email', {
              email: this.form.email
            })
        }).then(
          response => {
                console.log(response);
                // http success, call the mutator and change something in state
                this.submitStatus = 'SUCCESS';
                this.$router.push('/authenticate')
              },
              error => {
                console.log(error);
                // http failed, let the calling function know that action did not work out
                this.submitStatus = 'ERROR';
              }
        );
      }
    }
  }
};
</script>

<style>
#authFormWrapper {
  display: flex;
}
</style>
