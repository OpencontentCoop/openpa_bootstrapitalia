import '../scss/bootstrap-italia.scss'
import { Alert, Button, Carousel, Collapse, Dropdown, Modal, Offcanvas, Popover, ScrollSpy, Tab, Toast, Tooltip } from 'bootstrap'

import { loadPlugin } from './load-plugin'
import init from './plugins/init'
import loadFonts from './plugins/fonts-loader'
import * as icons from './icons'

import {
  // Dimmer,
  Notification,
  // Cookiebar,
  NavBarCollapsible,
  Accordion,
  NavScroll,
  CarouselBI,
  // FormValidate,
  // ValidatorSelectAutocomplete,
  // Input,
  // SelectAutocomplete,
  // InputSearchAutocomplete,
  // InputPassword,
  // InputNumber,
  // ProgressDonut,
  // UploadDragDrop,
  BackToTop,
  Sticky,
  HeaderSticky,
  HistoryBack,
  Forward,
  Masonry,
  List,
  Transfer,
} from './bootstrap-italia.esm'

loadPlugin(icons)
init()

export default {
  Alert,
  Button,
  Carousel,
  Collapse,
  Dropdown,
  Modal,
  Offcanvas,
  Popover,
  ScrollSpy,
  Tab,
  Toast,
  Tooltip,
  Accordion,
  BackToTop,
  CarouselBI,
  // Cookiebar,
  // Dimmer,
  // FormValidate,
  Forward,
  HistoryBack,
  // Input,
  // InputNumber,
  // InputPassword,
  // InputSearchAutocomplete,
  List,
  Masonry,
  NavBarCollapsible,
  NavScroll,
  Notification,
  // ProgressDonut,
  // SelectAutocomplete,
  Sticky,
  HeaderSticky,
  Transfer,
  // UploadDragDrop,
  // ValidatorSelectAutocomplete,
  loadFonts,
}
