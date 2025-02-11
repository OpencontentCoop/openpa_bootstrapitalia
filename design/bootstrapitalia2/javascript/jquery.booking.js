/*jshint esversion: 6 */
(function ($) {
  $.retryAjax = function (ajaxParams) {
    var errorCallback;
    ajaxParams.tryCount = (!ajaxParams.tryCount) ? 0 : ajaxParams.tryCount;
    ajaxParams.retryLimit = (!ajaxParams.retryLimit) ? 2 : ajaxParams.retryLimit;
    ajaxParams.suppressErrors = true;
    if (ajaxParams.error) {
      errorCallback = ajaxParams.error;
      delete ajaxParams.error;
    } else {
      errorCallback = function () {
      };
    }
    ajaxParams.complete = function (jqXHR, textStatus) {
      if (jqXHR && jqXHR.readyState === 0 && jqXHR.status === 0
        && $.inArray(textStatus, ['timeout', 'abort', 'error']) > -1) {
        this.tryCount++;
        if (this.tryCount <= this.retryLimit) {
          console.log('Connection error: retry', this.tryCount)
          if (this.tryCount === this.retryLimit) {
            this.error = errorCallback;
            delete this.suppressErrors;
          }
          $.ajax(this);
          return true;
        }
        return true;
      } else if (jqXHR.status > 399) {
        errorCallback(jqXHR)
      }
    };
    $.ajax(ajaxParams);
  };
}(jQuery));
(function ($, window, document, undefined) {

  "use strict"

  $.fn.resetSelect = function (preserve) {
    let container = $(this)
    let options = []
    if (preserve) {
      $(this).find('option').each(function () {
        if ($(this).val().length > 0) {
          options.push({'name': $(this).text(), 'value': $(this).val()})
        }
      })
    }
    container.html('<option value="">' + $(this).prev().text() + '</option>')
    if (preserve) {
      $.each(options, function () {
        container.append('<option value="' + this.value + '">' + this.name + '</option>')
      })
    }
    return this
  }

  let pluginName = "opencityBooking",
    defaults = {
      storageKey: null,
      tokenUrl: null,
      profileUrl: null,
      calendars: [],
      prefix: null,
      hasSession: false,
      debug: false,
      debugUserToken: null,
      forcePreselect: false,
      useAvailabilitiesCache: false
    }

  function Plugin(element, options) {
    this.element = element
    this.settings = $.extend({}, defaults, options)
    this.settings.debug = false
    let _token = '', _tokenNode = document.getElementById('ezxform_token_js');
    if (_tokenNode) _token = _tokenNode.getAttribute('title');
    this.settings.xtoken = _token;

    this.baseUrl = '/'
    if (typeof (this.settings.prefix) !== 'undefined' && this.settings.prefix !== '/') {
      this.baseUrl = this.settings.prefix + '/'
    }

    this.stepper = $('.steppers-header ul')
    this.stepperLoading = $('#stepper-loading')
    this.steps = this.stepper.find('li[data-step]')
    let stepsHash = []
    this.steps.each(function (i, v) {
      stepsHash.push({
        'index': i,
        'step': $(this).data('step')
      })
    })
    this.stepsHash = stepsHash

    this.spidAccess = $('#spid-access')
    this.privacyCheck = $('#privacyCheck').prop('checked', false)
    this.scheduler = $('#appointment-scheduler')
    this.hasScheduler = this.scheduler.length > 0
    this.eventCalendar = null
    if (!this.hasScheduler) {
      this.monthSelect = $('#appointment-month')
      this.firstMonth = $('option', this.monthSelect).first().val()
      this.openingHoursSelect = $('#appointment-hours').resetSelect()
      this.daySelect = $('#appointment-day').resetSelect()
    }

    this.placeSelect = $('input[name="place"]').prop('checked', false)
    this.officeSelect = $('#office-choice')
    this.subjectHiddenInput = $('input[name="subject-precompiled"]')
    this.subjectInput = $('input[name="subject"]').val('')
    this.detailInput = $('textarea[name="detail"]').val('')
    this.nameInput = $('input[name="name"]').val('')
    this.surnameInput = $('input[name="surname"]').val('')
    this.fiscalcodeInput = $('input[name="fiscalcode"]').val('')
    this.emailInput = $('input[name="email"]').val('')
    this.phoneInput = $('input[name="phone"]').val('')

    this.summary = null
    this.currentData = {
      'step': 0,
      'privacy': null,
      'office': null,
      'calendarFilter': [],
      'place': null,
      'month': null,
      'day': null,
      'openingHour': null,
      'subject': null,
      'detail': null,
      'applicantName': null,
      'applicantSurname': null,
      'applicantFiscalCode': null,
      'applicantEmail': null,
      'applicantPhone': null,
      'meeting': null,
      'schedulerEvent': null
    }
    this.cacheDayAvailabilities = []
    this.avoidApplicantModification = []
    this.storeMessage = $('#store-message')
    this.storeErrorMessage = $('#store-error')
    this.user = null;
    this.feedback = $('.feedback-container');
    this.errorContainer = $('.error-container');
    this.calendarFilterContainer = $('#appointment-calendars');
    this.cacheCalendars = this.settings.calendars
    this.meetingNumber = $('#meetingNumber')
    this.isSchedulerLoading = false;
    this.init()
  }

  // Avoid Plugin.prototype conflicts
  $.extend(Plugin.prototype, {

    debug: function (...data) {
      if (this.settings.debug) {
        let msg = data.shift()
        console.log("%c" + msg, "color:White;font-weight:bold; background-color: grey;", data)
      }
    },

    info: function (...data) {
      if (this.settings.debug) {
        let msg = data.shift()
        console.log("%c" + msg, "color:White;font-weight:bold; background-color:RoyalBlue;", data)
      }
    },

    warning: function (...data) {
      if (this.settings.debug) {
        let msg = data.shift()
        console.log("%c" + msg, "color:Black;font-weight:bold; background-color: yellow;", data)
      }
    },

    error: function (...data) {
      if (this.settings.debug) {
        let msg = data.shift()
        console.log("%c" + msg, "color:White;font-weight:bold; background-color:Red;", data)
      }
    },

    displayError: function (error) {
      if (typeof error === 'object' && error.hasOwnProperty('responseJSON') && error.responseJSON.hasOwnProperty('error')){
        console.log(error.responseJSON.error)
      } else {
        console.log(error)
      }
      let self = this
      self.removeStorage()
      $(self.element).find('.steppers').hide()
      $(self.element).find('.row.justify-content-center .cmp-hero').hide()
      $(self.element).find('.title-xsmall').hide()
      $(self.element).find('.step.container').hide()
      self.errorContainer.find('.row.justify-content-center .cmp-hero').show()
      self.scrollToTop()
      self.errorContainer.show()
    },

    scrollToTop: function () {
      $('html, body').animate({
        scrollTop: $("#booking-steppers").offset().top - 100
      }, 0);
    },

    init: function () {
      let self = this

      let data = self.getStoredData() || JSON.stringify(self.currentData)
      self.setCurrentData(JSON.parse(data))

      if (self.settings.profileUrl && self.settings.tokenUrl) {
        $.ajax({
          retryLimit: 1,
          url: self.settings.tokenUrl,
          dataType: 'json',
          xhrFields: {withCredentials: true},

          success: function (data) {
            self.debug('init', 'get auth token')
            let roles = self.parseToken(data.token).roles || []
            if (
              $.inArray('ROLE_SUPER_ADMIN', roles) > -1
              || $.inArray('ROLE_ADMIN', roles) > -1
              || $.inArray('ROLE_OPERATORE_ADMIN', roles) > -1
              || $.inArray('ROLE_OPERATOR', roles) > -1
            ) {
              self.loadWithoutUserToken()
            } else {
              self.loadWithUserToken(data.token)
              $('#step-summary button.save-desktop').addClass('d-lg-block')
              $('#step-summary button.save-mobile').removeClass('d-none').addClass('d-block d-lg-none');
            }
          },

          error: function () {
            self.spidAccess.removeClass('d-none')
            if (self.settings.debugUserToken) {
              self.info('init', 'set debug token')
              self.loadWithUserToken(self.settings.debugUserToken)

            } else if (self.settings.hasSession) {
              self.info('init', 'use current session')
              self.load()

            } else {
              self.debug('init', 'get anonym token')
              self.loadWithoutUserToken()
            }
          }
        })
      } else {
        self.displayError('profile or token url not found')
      }
    },

    loadWithoutUserToken: function () {
      let self = this
      self.getAnonymousToken(function (token) {
        self.restoreDraftIfNeeded(token, function () {
          self.load()
        })
      })
    },

    loadWithUserToken: function (token) {
      let self = this
      self.restoreDraftIfNeeded(token, function () {
        self.getUserProfile(token, function (user) {
          self.load(user)
        })
      })
    },

    parseToken: function (token) {
      let base64Url = token.split('.')[1]
      let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
      let jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function (c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)
      }).join(''))
      return JSON.parse(jsonPayload)
    },

    restoreDraftIfNeeded: function (currentToken, callback, context) {
      let self = this
      let meeting = self.currentData.meeting || null
      self.info('init', 'refresh meeting draft')
      $.retryAjax({
        type: "POST",
        url: self.baseUrl + 'openpa/data/booking/restore_meeting',
        data: {
          currentToken: currentToken,
          meeting: meeting
        },
        dataType: 'json',
        success: function (response) {
          self.setCurrentData('meeting', response.meeting)
          if ($.isFunction(callback)) {
            callback.call(context, response)
          }
        },
        error: function (jqXHR) {
          self.setCurrentData('meeting', null)
          if ($.isFunction(callback)) {
            callback.call(context, response)
          }
        }
      })
    },

    getAnonymousToken: function (callback, context) {
      let self = this
      $.retryAjax({
        url: self.settings.tokenUrl,
        dataType: 'json',
        type: "POST",
        success: function (data) {
          callback.call(context, data.token)
        },
        error: function () {
          callback.call(context, null)
        }
      })
    },

    getUserProfile: function (token, callback, context) {
      let self = this
      if (self.settings.profileUrl) {
        let tokenData = self.parseToken(token)
        $.retryAjax({
          url: self.settings.profileUrl + '/' + tokenData.id,
          dataType: 'json',
          headers: {Authorization: 'Bearer ' + token},
          success: function (data) {
            data.token = token
            if ($.isFunction(callback)) {
              callback.call(context, data)
            }
          },
          error: function () {
            if ($.isFunction(callback)) {
              callback.call(context, null)
            }
          }
        })
      } else if ($.isFunction(callback)) {
        callback.call(context, null)
      }
    },

    load: function (userData) {
      this.user = userData
      let self = this
      self.addListeners()

      if (userData) {
        self.avoidApplicantModification = ['name', 'surname', 'fiscalcode']
        self.debug('user-data', userData)
        self.setCurrentData('applicantName', userData.nome || '')
        self.setCurrentData('applicantSurname', userData.cognome || '')
        self.setCurrentData('applicantFiscalCode', userData.codice_fiscale || '')
        self.setCurrentData('applicantEmail', userData.email || '')
        self.setCurrentData('applicantPhone', userData.cellulare || userData.telefono || '')
      }
      if (self.subjectHiddenInput.length > 0) {
        self.setCurrentData('subject', self.subjectHiddenInput.val())
      }

      if (self.currentData.detail) self.detailInput.val(self.currentData.detail).trigger('change')
      if (self.currentData.applicantName) self.nameInput.val(self.currentData.applicantName).trigger('change')
      if (self.currentData.applicantSurname) self.surnameInput.val(self.currentData.applicantSurname).trigger('change')
      if (self.currentData.applicantFiscalCode) self.fiscalcodeInput.val(self.currentData.applicantFiscalCode).trigger('change')
      if (self.currentData.applicantEmail) self.emailInput.val(self.currentData.applicantEmail).trigger('change')
      if (self.currentData.applicantPhone) self.phoneInput.val(self.currentData.applicantPhone).trigger('change')
      self.privacyCheck.prop('checked', self.currentData.privacy).trigger('change')

      if (self.currentData.subject) {
        self.debug('preselect subject', self.currentData.subject)
        self.subjectInput.val(self.currentData.subject).trigger('change')
      } else {
        self.debug('invalid or missing preselect subject')
        self.subjectInput.trigger('change')
      }

      if (self.currentData.office && self.officeSelect.find('[value="' + self.currentData.office + '"]').length > 0) {
        self.debug('preselect office', self.currentData.office)
        self.officeSelect.val(self.currentData.office)
        if (!self.currentData.place) {
          self.officeSelect.trigger('change')
        } else {
          self.debug('preselect place', self.currentData.place)
          self.showPlaces()
        }
      } else if (self.officeSelect.find('option').length === 1) {
        self.officeSelect.val(self.officeSelect.find('option').first().val()).trigger('change')
      } else {
        self.officeSelect.val(self.officeSelect.find('option').first().val())
      }
      if (this.hasScheduler) {
        self.forceGoToCurrentStepIfNeeded('datetime')
      }else {
        if (self.currentData.month) {
          if (self.monthSelect.find('[value="' + self.currentData.month + '"]').length > 0) {
            self.debug('preselect month', self.currentData.month)
            self.monthSelect.find('[value="' + self.currentData.month + '"]').attr('selected', 'selected')
          } else {
            self.monthSelect.find('[value="' + self.firstMonth + '"]').attr('selected', 'selected')
            self.debug('invalid or missing preselect month', self.currentData.month)
          }
          self.forceGoToCurrentStepIfNeeded('datetime')
        } else {
          self.monthSelect.val(self.firstMonth).trigger('change')
          self.gotoStep(self.currentData.step, function () {
            self.makeSummary()
          })
        }
      }
    },

    addListeners: function () {
      let self = this
      $('[data-goto]').on('click', function (e) {
        let step = $(this).data('goto')
        if (step) {
          self.gotoStep(self.getStepIndex(step))
        }
        e.preventDefault();
      })

      $(window).on('hashchange', function (e) {
        if (location.hash.includes('#step-')) {
          let step = location.hash.replace('#step-', '')
          if (step && self.currentData.step !== self.getStepIndex(step)) {
            self.gotoStep(self.getStepIndex(step))
          }
        }
      })

      $('.step.container button[type="submit"]').on('click', function (e) {
        self.nextStep()
        e.preventDefault()
      })
      $('.step.container button.steppers-btn-prev').on('click', function (e) {
        self.prevStep()
        e.preventDefault()
      })

      $('#step-summary button.send').on('click', function (e) {
        $(this).attr('disabled', 'disabled').find('.text-button-sm').hide();
        $(this).find('.load-button').show()
        self.info('send-form')
        self.saveMeeting(function (response) {
          let code = response?.meeting?.code || response.dto.meetingCode || '';
          if (response?.meeting?.status === 0){
            $(self.element).find('.meeting-is-pending').show()
            $(self.element).find('.meeting-is-confirmed').hide()
          }else{
            $(self.element).find('.meeting-is-pending').hide()
            $(self.element).find('.meeting-is-confirmed').show()
          }
          self.removeStorage()
          $(self.element).find('.steppers').hide()
          $(self.element).find('.row.justify-content-center .cmp-hero').hide()
          $(self.element).find('.title-xsmall').hide()
          $(self.element).find('.step.container').hide()
          if (code.length > 0){
            self.meetingNumber.show().find('strong').text(code);
          } else {
            self.meetingNumber.hide();
          }
          self.feedback.find('[data-openinghourDay]').text(self.summary.openinghourDay)
          self.feedback.find('[data-openinghourFrom]').text(self.summary.openinghourHour.split(' - ')[0])
          self.feedback.find('[data-openinghourTo]').text(self.summary.openinghourHour.split(' - ')[1])
          self.feedback.find('[data-applicantEmail]').text(self.summary.applicantEmail)
          self.feedback.find('.row.justify-content-center .cmp-hero').show()
          window.scrollTo(0, 0);
          self.feedback.show()
        }, function (error) {
          self.displayError(error)
        })

        e.preventDefault()
      })
      $('#step-summary button.save').on('click', function (e) {
        self.info('save-form')
        self.saveMeetingDraft(function () {
          self.storeMessage.removeClass('d-none')
          setTimeout(function () {
            self.storeMessage.addClass('d-none')
          }, 3000)
        }, function () {
          self.storeErrorMessage.removeClass('d-none')
          setTimeout(function () {
            self.storeErrorMessage.addClass('d-none')
          }, 3000)
        })
        e.preventDefault()
      })

      self.privacyCheck.on('change', function () {
        if ($(this).is(':checked')) {
          self.setCurrentData('privacy', true)
        } else {
          self.setCurrentData('privacy', null)
        }
        self.onChangePrivacy()
      })

      if (!self.hasScheduler) {
        self.monthSelect.on('change', function () {
          self.setCurrentData('month', $(this).val())
          self.onChangeMonth()
        })
        self.openingHoursSelect.on('change', function () {
          self.setCurrentData('openingHour', $(this).val())
          self.onChangeOpeningHours()
        })
        self.daySelect.on('change', function () {
          self.setCurrentData('day', $(this).val())
          self.showHourAvailabilities()
        })
      } else {
        addEventListener("resize", (event) => {
          if (!self.eventCalendar || typeof self.eventCalendar.getView !== 'function') {
            return
          }
          if ((self.eventCalendar.getView().type === 'timeGridDay' && window.innerWidth > 768) || 
              (self.eventCalendar.getView().type === 'timeGridWeek' && window.innerWidth <= 768)) {
            self.resetScheduler()
          }
        });
      }
      self.placeSelect.on('change', function () {
        self.setCurrentData('place', $(this).attr('id'))
        self.setCurrentData('calendarFilter', [])
        self.onChangePlace()
      })

      self.officeSelect.on('change', function () {
        self.setCurrentData('office', $(this).val())
        self.onChangeOffice()
      })

      self.subjectInput.on('change input', function () {
        self.setCurrentData('subject', $(this).val())
        self.onChangeDetails()
      })

      self.detailInput.on('change input', function () {
        let value = $(this).val()
        self.debug('detail-length', value.length)
        let remain = 200 - value.length
        if (remain < 0) remain = 0
        $(this).parent().find('.detail-length').text(remain)
        if (value.length > 200) {
          self.showInputError($(this))
          self.setCurrentData('detail', null)
        } else {
          self.hideInputError($(this))
          self.setCurrentData('detail', value)
        }
        self.onChangeDetails()
      })

      $('button.clean-input').on('click', function (e) {
        $(this).prev().val('').trigger('change')
        e.preventDefault()
      })

      self.nameInput.on('change input', function () {
        let value = $(this).val()
        if (value) {
          self.setCurrentData('applicantName', value)
          self.onChangeApplicant()
          self.showCleanInputButton($(this))
        } else {
          self.setCurrentData('applicantName', null)
          self.hideCleanInputButton($(this))
        }
      })

      self.surnameInput.on('change input', function () {
        let value = $(this).val()
        if (value) {
          self.setCurrentData('applicantSurname', value)
          self.onChangeApplicant()
          self.showCleanInputButton($(this))
        } else {
          self.setCurrentData('applicantSurname', null)
          self.hideCleanInputButton($(this))
        }
      })

      self.fiscalcodeInput.on('change input', function () {
        let value = $(this).val()
        if (value) {
          self.hideInputError($(this))
          if (self.validateFiscalCode(value)) {
            self.setCurrentData('applicantFiscalCode', value)
            self.onChangeApplicant()
          } else {
            self.showInputError($(this))
          }
          self.showCleanInputButton($(this))
          $(this).val(value.toUpperCase())
        } else {
          self.setCurrentData('applicantFiscalCode', null)
        }
      })

      self.emailInput.on('change input', function () {
        let value = $(this).val()
        if (value) {
          self.hideInputError($(this))
          if (self.validateEmail(value)) {
            self.setCurrentData('applicantEmail', value)
            self.onChangeApplicant()
          } else {
            self.showInputError($(this))
          }
          self.showCleanInputButton($(this))
        } else {
          self.setCurrentData('applicantEmail', null)
          self.hideCleanInputButton($(this))
        }
      })

      self.phoneInput.on('change input', function () {
        let value = $(this).val()
        if (value) {
          self.hideInputError($(this))
          if (self.validatePhoneNumber(value)) {
            self.setCurrentData('applicantPhone', value)
            self.onChangeApplicant()
          } else {
            self.showInputError($(this))
          }
          self.showCleanInputButton($(this))
        } else {
          self.setCurrentData('applicantPhone', null)
          self.hideCleanInputButton($(this))
        }
      })

      $(self.element).find('.no-availabilities a').on('click', function () {
        self.markStepUnconfirmed('datetime', function () {
          self.setCurrentData('place', null)
          self.setCurrentData('day', null)
          self.setCurrentData('openingHour', null)
          if (self.hasScheduler) {
            self.resetScheduler()
          } else {
            self.daySelect.resetSelect()
            self.openingHoursSelect.resetSelect()
            self.monthSelect.find('option').attr('disabled', false)
            self.monthSelect.val(self.firstMonth).trigger('change')
          }
          self.placeSelect.prop('checked', false)
          $(self.element).find('.no-availabilities').hide()
          self.gotoStep(1)
        })
      })
    },

    setCurrentData: function (key, value) {
      if (typeof value !== 'undefined') {
        this.debug('set-data:' + key, value)
        this.currentData[key] = value
      } else if (typeof key !== 'string') {
        this.debug('set-data', key)
        this.currentData = key
      }
    },

    getStepIndex: function (step) {
      return this.stepsHash.map(function (step) {
        return step.step
      }).indexOf(step)
    },

    currentStep: function () {
      return $(this.steps[this.currentData.step])
    },

    stepContainer: function (step) {
      return $('#step-' + step)
    },

    currentStepContainer: function () {
      return this.stepContainer(this.currentStep().data('step'))
    },

    pushState: function () {
      if (history.pushState) {
        history.pushState(null, null, '#step-' + this.currentStep().data('step'))
      } else {
        location.hash = '#step-' + this.currentStep().data('step')
      }
      this.debug('push-state', this.currentStep().data('step'))
    },

    storeData: function () {
      if (typeof (Storage) !== "undefined") {
        sessionStorage.setItem(this.settings.storageKey, JSON.stringify(this.currentData))
        this.info('store-data', this.settings.storageKey, this.currentData)
      }
    },

    removeStorage: function () {
      if (typeof (Storage) !== "undefined") {
        sessionStorage.removeItem(this.settings.storageKey)
        this.info('remove-stored-data', this.settings.storageKey)
      }
    },

    getStoredData: function () {
      if (typeof (Storage) !== "undefined") {
        return sessionStorage.getItem(this.settings.storageKey)
      }
      return null
    },

    nextStep: function () {
      this.debug('goto-next-step')
      this.gotoStep(++this.currentData.step)
      this.storeData()
    },

    prevStep: function () {
      this.debug('goto-prev-step')
      this.gotoStep(--this.currentData.step)
    },

    gotoStep: function (index, callback, context) {
      if (index < 0) index = 0
      let current = this.getStepIndex(this.currentStep().data('step'))
      this.debug('goto-step', index)
      this.stepperLoading.hide()
      $('.step.container').hide()
      this.steps.removeClass('active')
      this.stepper.find('[data-status="step-status-active"]').attr('aria-hidden', true)
      this.setCurrentData('step', index)
      this.currentStep().addClass('active')
      this.currentStep().find('[data-status="step-status-active"]').attr('aria-hidden', false)
      this.currentStepContainer().show()
      this.pushState()
      if (current !== index) {
        this.scrollToTop()
      }
      if ($.isFunction(callback)) {
        callback.call(context, this.currentData)
      }
    },

    forceGoToCurrentStepIfNeeded: function (step) {
      this.debug('force-goto-step', step, this.getStepIndex(step), this.currentData.step)
      if (this.currentData.step > this.getStepIndex(step)) {
        this.setCurrentData('step', this.getStepIndex(step))
      }
      this.gotoStep(this.currentData.step)
    },

    markStepConfirmed: function (id, callback, context) {
      let currentStep = this.stepper.find('li[data-step="' + id + '"]')
      this.info('mark-step-as-confirmed', id)
      currentStep
        .addClass('confirmed')
        .find('.steppers-success').removeClass('invisible')
      currentStep.find('[data-status="step-status-confirmed"]').attr('aria-hidden', false)
      $('#step-' + id + ' button[type="submit"]').removeClass('disabled').removeAttr('disabled')
      if ($.isFunction(callback)) {
        callback.call(context, id)
      }
      this.makeSummary()
      this.storeData()
    },

    markStepUnconfirmed: function (id, callback, context) {
      let currentStep = this.stepper.find('li[data-step="' + id + '"]')
      this.info('mark-step-as-unconfirmed', id)
      currentStep
        .removeClass('confirmed')
        .find('.steppers-success').addClass('invisible')
      currentStep.find('[data-status="step-status-confirmed"]').attr('aria-hidden', true)
      $('#step-' + id + ' button[type="submit"]').addClass('disabled').attr('disabled', 'disabled')
      if ($.isFunction(callback)) {
        callback.call(context, id)
      }
    },

    isUseCalendarFilter: function () {
      let self = this
      return $('#' + self.currentData.place).data('with_filters') === 1;
    },

    filterCalendars: function () {
      let calendars = this.isUseCalendarFilter() ? this.getCheckedCalendars(true) : ''
      if (calendars.length === 0) {
        calendars = $('#' + this.currentData.place).data('calendars') || []
      }
      return calendars;
    },

    getCheckedCalendars: function (asString = false) {
      let cals = []
      this.calendarFilterContainer.find('input[name="calendars[]"]:checked').each(function () {
        cals.push($(this).val())
      })
      return asString ? cals.join(',') : cals;
    },

    buildMonthSelect: function (maxMonthIndex) {
      let self = this
      self.error('build-month-select', maxMonthIndex);
      if (self.monthSelect.find('option[value=""]').length > 0){
        self.error('fix-month-select', self.monthSelect.find('option[value=""]').length);
        maxMonthIndex++
      }
      self.monthSelect.find('option')
        .attr('disabled', true)
        .hide()        
      
      let maxDate = moment().add(maxMonthIndex, 'months')
      self.error('max-date-available', maxDate.toString())
      let index = 0;
      $('option', self.monthSelect).each(function(){
        let monthYear = $(this).val()
        if (index === 0){
          $(this).attr('disabled', false).show()
          $(this).prop('selected', 'selected')
          self.setCurrentData('month', $(this).val())
          self.setCurrentData('day', null)
          self.setCurrentData('openingHour', null)
        }else if (monthYear.length > 0 && maxDate.isSameOrAfter(moment(monthYear+'-01'))){
          $(this).attr('disabled', false).show()
        }
        index++;
      })
      self.error('built-month-select', self.monthSelect.find('option:selected').val(), maxMonthIndex);
    },

    buildCalendarFilter: function () {
      let self = this
      self.calendarFilterContainer.html('')
      let placeInput = $('#' + this.currentData.place)
      if (!self.isUseCalendarFilter()) {
        if (self.hasScheduler){
          self.resetScheduler()
        }else {
          let maxMonthIndex = placeInput.data('month_interval')
          self.buildMonthSelect(maxMonthIndex)
        }
        return
      }
      let calendars = placeInput.data('calendars').split(',')
      let currentFilters = self.currentData.calendarFilter || []

      function isSelected(id, index) {
        let currentMeetingCalendar = self.currentData.openingHour ? self.currentData.openingHour.split('|')[0] : false
        if (currentMeetingCalendar && $.inArray(currentMeetingCalendar, calendars) > -1) {
          return currentMeetingCalendar === id
        }
        return (currentFilters.length === 0 && index === 0) || $.inArray(id, currentFilters) > -1;
      }

      $.each(calendars, function (i,v) {
        let check = $('<div class="form-check col-md-6 my-0 py-0 calendar-filter"></div>')
        let input = $('<input class="form-check-input" name="calendars[]" type="radio" value="' + this + '" id="calendar-' + this + '">')
          .prop('checked', isSelected(this, i))
          .on('change', function (e) {
            let maxMonthIndex = 1;
            let checked = self.getCheckedCalendars()
            if (checked.length === 0) {
              self.setCurrentData('calendarFilter', [])
              let firstSelected = self.calendarFilterContainer.find('input[name="calendars[]"]')
                .first()
                .prop('checked', true)
              maxMonthIndex = self.cacheCalendars[firstSelected.val()].month_interval ?? maxMonthIndex
              $('[data-placeDetail]').html('')
            } else {
              $.each(checked, function (){
                let calMonthIndex = self.cacheCalendars[this].month_interval ?? 0
                if (calMonthIndex > maxMonthIndex){
                  maxMonthIndex = calMonthIndex
                }
              })
              self.setCurrentData('calendarFilter', checked)
              $('[data-placeDetail]').html($(e.target).next().text())
            }
            if (calendars.length > 1) {
              self.storeData()
              self.markStepUnconfirmed('datetime')
              self.setCurrentData('month', null)
              self.setCurrentData('day', null)
              self.setCurrentData('openingHour', null)
              self.storeData()
              if (self.hasScheduler) {
                self.resetScheduler()
                $('.scheduler-summary').hide();
              }else {
                self.unfreezeAppointmentSelection()
                self.monthSelect.resetSelect(true)
                self.daySelect.resetSelect()
                self.openingHoursSelect.resetSelect()
                self.buildMonthSelect(maxMonthIndex)
                self.onChangeMonth()
              }
            }
          })
          .appendTo(check)

        let title = self.cacheCalendars[this].title ?? '<i class="fa fa-circle-o-notch fa-spin fa-fw"></i>';
        let label = $('<label class="form-check-label" for="calendar-' + this + '">'+title+'</label>').appendTo(check)
        self.calendarFilterContainer.append(check)
      })
      self.calendarFilterContainer.find('input[name="calendars[]"]').first().trigger('change')
    },

    getSchedulerSettings: function (calendars, callback, context){
      let self = this
      $.retryAjax({
        dataType: "json",
        url: self.baseUrl + 'openpa/data/booking/scheduler',
        data: {
          calendars: calendars
        },
        success: function (response) {
          if ($.isFunction(callback)) {
            callback.call(context, response)
          }
        },
        error: function (jqXHR) {
          self.displayError(jqXHR)
        }
      });
    },

    selectSchedulerEvent: function(event, refreshSummary){
      let self = this
      let slot = event.extendedProps
      let slotId = [slot.calendar_id, slot.opening_hour_id, slot.date, slot.start_time, slot.end_time].join('|')
      let dateParts = slot.date.split('-');
      if (refreshSummary) {
        $('.scheduler-summary p.data-text').text('---')
      }
      $('.scheduler-summary').show();
      self.setCurrentData('openingHour', slotId)
      self.setCurrentData('month', dateParts[0]+'-'+dateParts[1])
      self.setCurrentData('day', dateParts[2])
      if (self.currentData.schedulerEvent
        && moment(self.currentData.schedulerEvent.start).format('WW') !== moment(event.start).format('WW')){
        self.eventCalendar.removeEventById(self.currentData.schedulerEvent.id)
      }
      self.setCurrentData('schedulerEvent', event)
      self.onChangeOpeningHours()
    },

    resetScheduler: function (){
      let self = this
      if (self.isSchedulerLoading) {
        return
      }
      self.isSchedulerLoading = true;
      $('[name="calendars[]"]').not(':checked').attr('disabled','disabled')
      let calendars = self.filterCalendars()
      self.debug('reset-scheduler', calendars)
      if (calendars.length > 0) {
        if (self.eventCalendar) {
          self.eventCalendar.destroy()
        }
        self.getSchedulerSettings(calendars, function (settings){
          let startDate = settings.firstAvailability;
          if (self.currentData.schedulerEvent) {
            startDate = self.currentData.schedulerEvent.extendedProps.date
          }
          if (!startDate) {
            const dayINeed = 4; // for Thursday
            const today = moment().isoWeekday();
            startDate = moment().isoWeekday(dayINeed).format('YYYY-MM-DD')
            if (today > dayINeed) {
              // otherwise, give me *next week's* instance of that same day
              startDate = moment().add(1, 'weeks').isoWeekday(dayINeed).format('YYYY-MM-DD')
            }
          }

          self.eventCalendar = new EventCalendar(self.scheduler[0], {
            view: window.innerWidth > 768 ? 'timeGridWeek': 'timeGridDay',
            slotMinTime: settings.minTime,
            slotMaxTime: settings.maxTime,
            slotDuration: settings.slotDuration,
            views: {
              timeGridWeek: {
                allDaySlot: false,
                firstDay: 1,
                hiddenDays: settings.hiddenDays,
              },
              timeGridDay: {
                allDaySlot: false,
                firstDay: 1,
                hiddenDays: settings.hiddenDays,
                slotHeight: 48
              }
            },
            eventClick: function (info) {
              $('article.ec-event').removeClass('selected')
              $(info.el).addClass('selected')
              self.selectSchedulerEvent(info.event, true)
            },
            loading: function (isLoading) {
              // console.log(isLoading)
            },
            locale: 'it-IT',
            date: startDate,
            buttonText: {
              today: 'Oggi'
            },
            eventSources: [{
              events: function (fetchInfo, successCallback, failureCallback) {
                $.retryAjax({
                  dataType: "json",
                  url: self.baseUrl + 'openpa/data/booking/availabilities_by_range',
                  data: {
                    calendars: calendars,
                    start: moment(fetchInfo.start).format('YYYY-MM-DD'),
                    end: moment(fetchInfo.end).subtract(1, 'minute').format('YYYY-MM-DD')
                  },
                  success: function (response) {
                    if (self.currentData.schedulerEvent && calendars.includes(self.currentData.schedulerEvent.extendedProps.calendar_id)) {
                      response = response.filter(function( obj ) {
                        return obj.id !== self.currentData.schedulerEvent.id;
                      });
                      self.currentData.schedulerEvent.start = self.currentData.schedulerEvent.extendedProps.date+' '+self.currentData.schedulerEvent.extendedProps.start_time
                      self.currentData.schedulerEvent.end = self.currentData.schedulerEvent.extendedProps.date+' '+self.currentData.schedulerEvent.extendedProps.end_time
                      self.currentData.schedulerEvent.classNames = ['selected']
                      response.push(self.currentData.schedulerEvent)
                      $('article.ec-event').removeClass('selected')
                      self.selectSchedulerEvent(self.currentData.schedulerEvent, false)
                    }
                    successCallback(response)
                  },
                  error: function (jqXHR) {
                    self.displayError(jqXHR)
                  }
                });
              }
            }]
          });
          self.isSchedulerLoading = false;
          $('[name="calendars[]"]').not(':checked').removeAttr('disabled');
          self.eventCalendar.refetchEvents()
        })
      }
    },

    renderCalendarLabel: function (id, label) {
      let self = this
      
      function renderLabel(text, id) {
        let render = text
        if (self.settings.debug) {
          render += ' (' + id + ')'
        }
        return render
      }

      let inCache = self.cacheCalendars[id] || null
      if (inCache) {
        label.text(renderLabel(inCache.title || '?', id))
      } else {
        self.debug('get-calendar', id)
        $.retryAjax({
          dataType: "json",
          url: self.baseUrl + 'openpa/data/booking/calendar/' + id,
          success: function (response) {
            self.cacheCalendars[id] = response
            label.text(renderLabel(self.cacheCalendars[id].title || '?', id))
          },
          error: function (jqXHR) {
            self.error(jqXHR)
          }
        });
      }
    },

    freezeAppointmentSelection: function () {
      this.stepContainer('datetime').find('.appointment-select').addClass('freeze')
    },

    unfreezeAppointmentSelection: function () {
      let self = this
      this.stepContainer('datetime').find('.appointment-select').removeClass('freeze')
      if (this.isUseCalendarFilter()) {
        this.calendarFilterContainer.find('.calendar-filter').each(function () {
          self.renderCalendarLabel($(this).find('input').val(), $(this).find('label'))
        })
      }
    },

    showHourAvailabilities: function () {
      let self = this
      this.openingHoursSelect.resetSelect()
      this.markStepUnconfirmed('datetime')
      if (this.currentData.place && this.currentData.day) {
        this.debug('find-hours-availabilities')
        this.freezeAppointmentSelection()
        $.retryAjax({
          dataType: "json",
          url: this.baseUrl + 'openpa/data/booking/availabilities_by_day',
          data: {
            calendars: this.filterCalendars(),
            day: self.currentData.day
          },
          success: function (response) {
            self.unfreezeAppointmentSelection()
            let hourAvailabilities = []
            $.each(response, function () {
              let slotId = [this.calendar_id, this.opening_hour_id, this.date, this.start_time, this.end_time].join('|')
              hourAvailabilities.push(slotId)
              self.openingHoursSelect.append('<option value="' + slotId + '">' + this.start_time + ' - ' + this.end_time + '</option>')
            })
            if (self.settings.forcePreselect && self.hasCurrentMeeting() && $.inArray(self.currentData.openingHour, hourAvailabilities) === -1) {
              self.info('force preselected openingHour', self.currentData.openingHour)
              hourAvailabilities.push(self.currentData.openingHour)
              self.openingHoursSelect.append('<option value="' + self.currentData.openingHour + '">'
                + self.currentData.openingHour.split('|')[3] + ' - ' + self.currentData.openingHour.split('|')[4] + '</option>')
              self.openingHoursSelect.html(self.openingHoursSelect.find('option').sort(function (x, y) {
                if ($(x).attr('value').length === 0) return -1;
                return $(x).text() > $(y).text() ? 1 : -1;
              }));
            }
            self.debug('hours-availabilities', hourAvailabilities)
            if (self.currentData.month && self.currentData.day && self.currentData.openingHour && $.inArray(self.currentData.openingHour, hourAvailabilities) > -1) {
              self.debug('preselected openingHour', self.currentData.openingHour)
              self.openingHoursSelect.val(self.currentData.openingHour).trigger('change')
              self.makeSummary()
            } else {
              self.debug('invalid or missing preselected openingHour', self.currentData.openingHour)
              self.openingHoursSelect.val('')
              self.forceGoToCurrentStepIfNeeded('datetime')
            }
          },
          error: function (jqXHR) {
            self.displayError(jqXHR)
          }
        });
      }
    },

    findDayAvailabilities: function (data, callback, context) {
      let self = this
      let cacheKey = JSON.stringify(data)
      let inCache = self.cacheDayAvailabilities[cacheKey] || null
      if (self.settings.useAvailabilitiesCache && inCache && $.isFunction(callback)) {
        self.debug('get-day-availabilities-from-cache', cacheKey)
        callback.call(context, inCache)
      } else {
        self.debug('find-day-availabilities', cacheKey)
        $.retryAjax({
          dataType: "json",
          url: self.baseUrl + 'openpa/data/booking/availabilities',
          data: data,
          success: function (response) {
            let dayAvailabilities = response.availabilities
            self.cacheDayAvailabilities[cacheKey] = dayAvailabilities
            self.debug('day-availabilities', dayAvailabilities)
            if ($.isFunction(callback)) {
              callback.call(context, dayAvailabilities)
            }
          },
          error: function (jqXHR) {
            self.displayError(jqXHR)
          }
        });
      }
    },

    showDayAvailabilities: function (callback, context) {
      let self = this
      self.markStepUnconfirmed('datetime', function () {
        if (!self.hasScheduler) {
          self.daySelect.resetSelect()
          self.openingHoursSelect.resetSelect()
        }
      })
      let calendars = this.filterCalendars()
      if (self.hasScheduler){
        self.debug('looking-for-week-availabilities', self.currentData.month, self.currentData.place, calendars)
      } else {
        self.debug('looking-for-day-availabilities', self.currentData.month, self.currentData.place, calendars)
        let container = self.stepContainer('datetime').find('.appointment-select');
        if (self.currentData.place && self.currentData.month) {
          self.freezeAppointmentSelection()
          self.daySelect.resetSelect()
          self.findDayAvailabilities({
            calendars: calendars,
            month: self.currentData.month
          }, function (dayAvailabilities) {
            if (dayAvailabilities.length === 0 && self.hasCurrentMeeting()) {
              dayAvailabilities.push({
                'data': self.currentData.day,
                'name': self.currentData.day
              })
            }
            if (dayAvailabilities.length === 0) {
              self.monthSelect.find('[value="' + self.currentData.month + '"]').attr('disabled', 'disabled')
              let next = $('option:selected', self.monthSelect).next().attr('value')
              if (next) {
                self.debug('no-day-for-month-try-next', next)
                self.monthSelect.val(next).trigger('change')
              } else {
                self.unfreezeAppointmentSelection()
                $(self.element).find('.no-availabilities').show()
              }
            } else {
              self.unfreezeAppointmentSelection()
              let dayAvailabilitiesValues = []
              $.each(dayAvailabilities, function () {
                dayAvailabilitiesValues.push(this.date)
                self.daySelect.append('<option value="' + this.date + '">' + this.name + '</option>')
              })
              if (self.settings.forcePreselect && self.hasCurrentMeeting() && $.inArray(self.currentData.day, dayAvailabilitiesValues) === -1) {
                self.info('force preselected day', self.currentData.day)
                dayAvailabilitiesValues.push(self.currentData.day)
                self.daySelect.append('<option value="' + self.currentData.day + '">' + self.currentData.day + '</option>')
                self.daySelect.html(self.daySelect.find('option').sort(function (x, y) {
                  if ($(x).attr('value').length === 0) return -1;
                  return $(x).attr('value') > $(y).attr('value') ? 1 : -1;
                }));
              }
              if (self.currentData.day && $.inArray(self.currentData.day, dayAvailabilitiesValues) > -1) {
                self.debug('preselected day', self.currentData.day)
                self.daySelect.val(self.currentData.day).trigger('change')
                self.makeSummary()
              } else {
                self.debug('invalid or missing preselected day', self.currentData.day)
                self.daySelect.val('')
                self.showHourAvailabilities()
                self.forceGoToCurrentStepIfNeeded('datetime')
              }
            }
            if ($.isFunction(callback)) {
              callback.call(context, dayAvailabilities)
            }
          })
        }
      }
    },

    onChangeOffice: function () {
      let self = this
      this.debug('change-office', this.currentData.office)
      this.placeSelect.prop('checked', false)
      this.markStepUnconfirmed('datetime', function () {
        self.setCurrentData('place', null)
        self.setCurrentData('day', null)
        self.setCurrentData('openingHour', null)
        if (self.hasScheduler){
          //self.resetScheduler()
        } else {
          self.daySelect.resetSelect()
          self.openingHoursSelect.resetSelect()
          self.monthSelect.find('option').attr('disabled', false)
          self.monthSelect.val(self.firstMonth).trigger('change')
        }
      })
      this.markStepUnconfirmed('place', function () {
        $('[data-placeTitle]').html('')
        $('[data-placeDetail]').html('')
        $('[data-placeAddress]').html('')
        $('[data-placeOpening]').html('')
      })
      this.showPlaces()
    },

    showPlaces: function () {
      let fieldset = $('#step-place fieldset')
      fieldset.removeClass('d-none')
      $('[data-office]').addClass('d-none')
      if (this.currentData.office) {
        let placesByOffice = $('[data-office="' + this.currentData.office + '"]')
        placesByOffice.removeClass('d-none')
        if (placesByOffice.length === 1) {
          placesByOffice.find('input[name="place"]').prop('checked', true).trigger('change')
        } else if (this.currentData.place) {
          let currentPlace = $('#' + this.currentData.place)
          if (currentPlace.length > 0 && currentPlace.attr('id').startsWith('place-' + this.currentData.office)) {
            currentPlace.prop('checked', true).trigger('change')
          } else {
            this.setCurrentData('place', null)
          }
        }
      } else {
        fieldset.addClass('d-none')
      }
    },

    onChangePrivacy: function () {
      this.debug('change-privacy', this.currentData.privacy)
      if (this.currentData.privacy) {
        $('#privacyCheck').prop('checked', true)
        this.markStepConfirmed('auth')
      } else {
        this.markStepUnconfirmed('auth')
      }
    },

    onChangeMonth: function () {
      this.debug('change-month', this.currentData.month)
      this.showDayAvailabilities()
    },

    onChangeOpeningHours: function () {
      let self = this
      this.debug('change-openingHour', this.currentData.openingHour)
      if (this.currentData.openingHour && this.currentData.day && this.currentData.month) {
        self.saveMeetingDraft(
          function () {
            self.markStepConfirmed('datetime')
          },
          function () {
            self.markStepUnconfirmed('datetime')
            $(self.element).find('.no-availabilities').show()
            if (self.hasScheduler) {
              $('article.ec-event').removeClass('selected')
              self.setCurrentData('schedulerEvent', null)
              $('.scheduler-summary').hide();
              self.storeData()
            }
          }
        )
      }
    },

    saveMeeting: function (callback, errorCallback, context) {
      this.warning('save-meeting', this.currentData.openingHour)
      if (this.currentData.openingHour) {
        let calendar_id, opening_hour_id, day, start_time, end_time
        [calendar_id, opening_hour_id, day, start_time, end_time] = this.currentData.openingHour.split('|')
        let postData = {
          calendar: calendar_id,
          opening_hour_id: opening_hour_id,
          date: day,
          to_time: end_time,
          from_time: start_time,
          user: this.user?.id || null,
          ezxform_token: this.settings.xtoken,
          meeting: this.currentData.meeting,
          email: this.summary.applicantEmail,
          phone_number: this.summary.applicantPhone,
          fiscal_code: this.summary.applicantFiscalCode,
          name: this.summary.applicantName,
          surname: this.summary.applicantSurname,
          user_message: this.summary.detailsText,
          motivation_outcome: $('[data-motivation_outcome]').html(),
          reason: this.summary.subjectText,
          place: $('[data-placeTitle]').html() + ' ' + $('[data-placeAddress]').html() + ' ' + $('[data-placeDetail]').html()
        }
        let self = this
        $.retryAjax({
          type: "POST",
          url: self.baseUrl + 'openpa/data/booking/meeting',
          data: postData,
          dataType: 'json',
          success: function (response) {
            self.setCurrentData('meeting', response)
            if ($.isFunction(callback)) {
              callback.call(context, response)
            }
          },
          error: function (jqXHR) {
            self.setCurrentData('meeting', null)
            if ($.isFunction(errorCallback)) {
              errorCallback.call(context, jqXHR)
            }
          }
        })
      }
    },

    saveMeetingDraft: function (callback, errorCallback, context) {
      this.warning('save-meeting-draft', this.currentData.openingHour)
      if (this.currentData.openingHour) {
        let calendar_id, opening_hour_id, day, start_time, end_time
        [calendar_id, opening_hour_id, day, start_time, end_time] = this.currentData.openingHour.split('|')
        let postData = {
          calendar: calendar_id,
          date: day,
          opening_hour_id: opening_hour_id,
          to_time: end_time,
          from_time: start_time,
          ezxform_token: this.settings.xtoken,
          meeting: this.currentData.meeting,
          place: $('[data-placeTitle]').html() + ' ' + $('[data-placeAddress]').html() + ' ' + $('[data-placeDetail]').html()
        }
        let self = this
        $.retryAjax({
          type: "POST",
          url: self.baseUrl + 'openpa/data/booking/draft_meeting',
          data: postData,
          dataType: 'json',
          success: function (response) {
            self.setCurrentData('meeting', response.data)
            if ($.isFunction(callback)) {
              callback.call(context, response)
            }
          },
          error: function (response) {
            self.setCurrentData('meeting', null)
            self.error('error-save-meeting-draft', response.responseJSON.error || response);
            if ($.isFunction(errorCallback)) {
              errorCallback.call(context, response)
            }
          }
        })
      }
    },

    onChangePlace: function () {
      let self = this
      self.debug('change-place', self.currentData.place)
      if (self.currentData.place) {
        self.markStepConfirmed('place', function () {
          let placeInput = $('#' + self.currentData.place)
          let placeContainer = placeInput.parents('[data-place]')
          $('[data-placeTitle]').html(placeContainer.find('[data-title]').html())
          $('[data-placeAddress]').html(placeContainer.find('[data-address]').html())
          $('[data-placeOpening]').html(placeContainer.find('[data-opening]').html())
          self.buildCalendarFilter()
          self.showDayAvailabilities()
        })
      }
    },

    onChangeDetails: function () {
      this.debug('change-details', this.currentData.subject, this.currentData.detail)
      if (this.currentData.subject && this.currentData.detail) {
        this.markStepConfirmed('details')
      } else {
        this.markStepUnconfirmed('details')
      }
    },

    onChangeApplicant: function () {
      this.debug('change-applicant')
      if (this.currentData.applicantEmail
        && this.currentData.applicantFiscalCode
        && this.currentData.applicantName
        && this.currentData.applicantPhone
        && this.currentData.applicantSurname) {
        this.markStepConfirmed('applicant')
      } else {
        this.markStepUnconfirmed('applicant')
      }
      this.makeSummary()
    },

    validateFiscalCode: function (cfins) {
      let cf = cfins.toUpperCase()
      let cfReg = /^[A-Z]{6}\d{2}[A-Z]\d{2}[A-Z]\d{3}[A-Z]$/
      if (!cfReg.test(cf))
        return false
      let set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      let set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ"
      let setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      let setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX"
      let s = 0
      for (let i = 1; i <= 13; i += 2)
        s += setpari.indexOf(set2.charAt(set1.indexOf(cf.charAt(i))))
      for (let i = 0; i <= 14; i += 2)
        s += setdisp.indexOf(set2.charAt(set1.indexOf(cf.charAt(i))))
      return s % 26 === cf.charCodeAt(15) - 'A'.charCodeAt(0)
    },

    validatePhoneNumber: function (phoneNumber) {
      return phoneNumber.match(/\d{8}/g)
    },

    validateEmail: function (email) {
      let mailformat = /^([A-Za-z0-9_\-.])+@([A-Za-z0-9_\-.])+\.([A-Za-z]{2,4})$/
      return !!email.match(mailformat)
    },

    showCleanInputButton: function (input) {
      if ($.inArray(input.attr('name'), this.avoidApplicantModification) > -1) {
        input.attr('readonly', 'readonly')
      } else {
        input.next().removeClass('d-none')
      }
    },

    hideCleanInputButton: function (input) {
      if ($.inArray(input.attr('name'), this.avoidApplicantModification) === -1) {
        input.next().addClass('d-none')
      }
    },

    showInputError: function (input) {
      input.parent().find('.form-text').addClass('text-warning').addClass('font-weight-bold')
    },

    hideInputError: function (input) {
      input.parent().find('.form-text').removeClass('text-warning').removeClass('font-weight-bold')
    },

    makeSummary: function () {
      let stepContainer = $('#step-summary')
      stepContainer.find('[data-officeTitle]').html(this.officeSelect.find('option[value="' + this.currentData.office + '"]').text())
      if (this.hasScheduler) {
        if (this.currentData.schedulerEvent) {
          $('[data-openinghourDay]').html(moment(this.currentData.schedulerEvent.start).format('dddd, D MMMM YYYY'))
          $('[data-openinghourHour]').html(this.currentData.schedulerEvent.extendedProps.start_time + ' - ' + this.currentData.schedulerEvent.extendedProps.end_time)
        }
      } else {
        stepContainer.find('[data-openinghourDay]').html(this.daySelect.find('option[value="' + this.currentData.day + '"]').text())
        stepContainer.find('[data-openinghourHour]').html(this.openingHoursSelect.find('option[value="' + this.currentData.openingHour + '"]').text())
      }
      stepContainer.find('[data-subjectText]').html(this.currentData.subject)
      stepContainer.find('[data-detailsText]').html(this.currentData.detail)
      stepContainer.find('[data-applicantName]').html(this.currentData.applicantName)
      stepContainer.find('[data-applicantSurname]').html(this.currentData.applicantSurname)
      stepContainer.find('[data-applicantFiscalCode]').html(this.currentData.applicantFiscalCode)
      stepContainer.find('[data-applicantEmail]').html(this.currentData.applicantEmail)
      stepContainer.find('[data-applicantPhone]').html(this.currentData.applicantPhone)
      this.summary = {
        officeTitle: stepContainer.find('[data-officeTitle]').text(),
        openinghourDay: stepContainer.find('[data-openinghourDay]').text(),
        openinghourHour: stepContainer.find('[data-openinghourHour]').text(),
        subjectText: stepContainer.find('[data-subjectText]').text(),
        detailsText: stepContainer.find('[data-detailsText]').text(),
        applicantName: stepContainer.find('[data-applicantName]').text(),
        applicantSurname: stepContainer.find('[data-applicantSurname]').text(),
        applicantFiscalCode: stepContainer.find('[data-applicantFiscalCode]').text(),
        applicantEmail: stepContainer.find('[data-applicantEmail]').text(),
        applicantPhone: stepContainer.find('[data-applicantPhone]').text(),
      }
      this.debug('make-summary', this.summary)
    },

    hasCurrentMeeting: function () {
      let hasValues = this.currentData.meeting?.id && this.currentData.openingHour && this.currentData.day
      if (hasValues) {
        let exp = this.currentData.meeting.expiration_time || this.currentData.meeting.draft_expiration || null
        if (!exp) {
          let updatedAt = this.currentData.meeting.updated_at || null
          if (updatedAt) {
            exp = new Date(updatedAt)
            exp.setMinutes(exp.getMinutes() + 10);
          }
        } else {
          exp = new Date(exp);
        }
        try {
          if (!exp || exp < (new Date())) {
            this.error('current meeting is expired', this.currentData.meeting, exp)
            return false
          } else {
            this.warning('current meeting is valid', this.currentData.meeting, exp)
            return true
          }
        } catch (error) {
          this.error('invalid meeting expiration', this.currentData.meeting, exp)
          return false
        }
      }
      this.debug('no current meeting')
      return false;
    }
  })

  $.fn[pluginName] = function (options) {
    return this.each(function () {
      if (!$.data(this, "plugin_" + pluginName)) {
        $.data(this, "plugin_" +
          pluginName, new Plugin(this, options))
      }
    })
  }

})(jQuery, window, document)
