<template>
  <div
    class="w-full h-full bg-slate-50 flex flex-col"
    @keydown.esc="closeWindow"
  >
    <div
      class="header-wrap bg-white"
      :class="{ expanded: !isHeaderCollapsed, collapsed: isHeaderCollapsed }"
    >
      <transition
        enter-active-class="transition-all delay-200 duration-300 ease-in"
        leave-active-class="transition-all duration-200 ease-out"
        enter-class="opacity-0"
        enter-to-class="opacity-100"
        leave-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <chat-header-expanded
          v-if="!isHeaderCollapsed"
          :intro-heading="channelConfig.welcomeTitle"
          :intro-body="channelConfig.welcomeTagline"
          :avatar-url="channelConfig.avatarUrl"
          :show-popout-button="appConfig.showPopoutButton"
        />
        <chat-header
          v-if="isHeaderCollapsed"
          :title="headerChatTitle"
          :avatar-url="channelConfig.avatarUrl"
          :show-popout-button="appConfig.showPopoutButton"
          :available-agents="availableAgents"
        />
      </transition>
    </div>
    <banner />
    <transition
      enter-active-class="transition-all delay-300 duration-300 ease-in"
      leave-active-class="transition-all duration-200 ease-out"
      enter-class="opacity-0"
      enter-to-class="opacity-100"
      leave-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <router-view />
    </transition>
    <branding />
  </div>
</template>
<script>
import Banner from '../Banner.vue';
import Branding from 'shared/components/Branding.vue';
import ChatHeader from '../ChatHeader.vue';
import ChatHeaderExpanded from '../ChatHeaderExpanded.vue';
import configMixin from '../../mixins/configMixin';
import { mapGetters } from 'vuex';
import { IFrameHelper } from 'widget/helpers/utils';

export default {
  components: {
    Banner,
    Branding,
    ChatHeader,
    ChatHeaderExpanded,
  },
  mixins: [configMixin],
  data() {
    return {
      showPopoutButton: false,
    };
  },
  computed: {
    ...mapGetters({
      allAgents: 'agent/allAgents',
      availableAgents: 'agent/availableAgents',
      appConfig: 'appConfig/getAppConfig',
    }),
    headerChatTitle() {
      let chatTitle = this.channelConfig.websiteName;
      let firstAgent = null;
      if (this.allAgents && this.allAgents.length > 0) {
        firstAgent = this.allAgents[0];
        if (firstAgent) {
          chatTitle = firstAgent.name;
        }
      }
      return chatTitle;
    },
    isHeaderCollapsed() {
      if (!this.hasIntroText) {
        return true;
      }
      return this.$route.name !== 'home';
    },
    hasIntroText() {
      return (
        this.channelConfig.welcomeTitle || this.channelConfig.welcomeTagline
      );
    },
  },
  methods: {
    closeWindow() {
      IFrameHelper.sendMessage({ event: 'closeWindow' });
    },
  },
};
</script>

<style scoped lang="scss">
@import '~widget/assets/scss/variables';
@import '~widget/assets/scss/mixins';

.header-wrap {
  flex-shrink: 0;
  transition: max-height 300ms;
  z-index: 99;
  @include shadow-large;

  &.expanded {
    max-height: 16rem;
  }

  &.collapsed {
    max-height: 4.5rem;
  }

  @media only screen and (min-device-width: 320px) and (max-device-width: 667px) {
    border-radius: 0;
  }
}
</style>
