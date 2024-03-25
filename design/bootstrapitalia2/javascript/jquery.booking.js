/*jshint esversion: 6 */
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
      prefix: null,
      hasSession: false,
      debug: false,
      debugUserToken: null,
      forcePreselect: true,
      useAvailabilitiesCache: false
    }

  function Plugin(element, options) {
    this.element = element
    this.settings = $.extend({}, defaults, options)

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
    this.monthSelect = $('#appointment-month')
    this.firstMonth = $('option', this.monthSelect).first().val()
    this.openingHoursSelect = $('#appointment-hours').resetSelect()
    this.daySelect = $('#appointment-day').resetSelect()
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
      'meeting': null
    }
    this.cacheDayAvailabilities = []
    this.avoidApplicantModification = false
    this.storeMessage = $('#store-message')
    this.storeErrorMessage = $('#store-error')
    this.user = null;
    this.feedback = $('.feedback-container');
    this.errorContainer = $('.error-container');
    this.calendarFilterContainer = $('#appointment-calendars');
    this.cacheCalendars = []

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
      console.log(error)
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
        self.debug('init', 'get auth token')
        $.ajax({
          url: self.settings.tokenUrl,
          dataType: 'json',
          xhrFields: {withCredentials: true},

          success: function (data) {
            self.restoreDraftIfNeeded(data.token, function () {
              self.getUserProfile(data.token, function (user) {
                self.load(user)
              })
            })
          },

          error: function () {
            self.spidAccess.removeClass('d-none')

            if (self.settings.debugUserToken) {
              self.info('init', 'set debug token')
              self.restoreDraftIfNeeded(self.settings.debugUserToken, function () {
                self.getUserProfile(self.settings.debugUserToken, function (user) {
                  self.load(user)
                })
              })

            } else if (self.settings.hasSession) {
              self.info('init', 'use current session')
              self.load()

            } else {

              self.debug('init', 'get anonym token')
              self.getAnonymousToken(function (token) {
                self.restoreDraftIfNeeded(token, function () {
                  self.load()
                })
              })
            }
          }
        })
      } else {
        self.displayError('profile or token url not found')
      }
    },

    restoreDraftIfNeeded: function (currentToken, callback, context) {
      let self = this
      let meeting = self.currentData.meeting || null
      self.info('init', 'refresh meeting draft')
      $.ajax({
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
      $.ajax({
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
        function parseJwt(token) {
          let base64Url = token.split('.')[1]
          let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
          let jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function (c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)
          }).join(''))
          return JSON.parse(jsonPayload)
        }

        let tokenData = parseJwt(token)
        $.ajax({
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
        self.avoidApplicantModification = true
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

      $(window).on('hashchange', function () {
        let step = location.hash.replace('#step-', '')
        if (step && self.currentData.step !== self.getStepIndex(step)) {
          self.gotoStep(self.getStepIndex(step))
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
          self.removeStorage()
          $(self.element).find('.steppers').hide()
          $(self.element).find('.row.justify-content-center .cmp-hero').hide()
          $(self.element).find('.title-xsmall').hide()
          $(self.element).find('.step.container').hide()
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
          self.daySelect.resetSelect()
          self.openingHoursSelect.resetSelect()
          self.monthSelect.find('option').attr('disabled', false)
          self.monthSelect.val(self.firstMonth).trigger('change')
          self.placeSelect.prop('checked', false)
          $(self.element).find('.no-availabilities').hide()
          self.gotoStep(1)
        })
      })
    },

    setCurrentData: function (key, value) {
      if (typeof value !== 'undefined') {
        this.currentData[key] = value
        this.debug('set-data:' + key, value)
      } else {
        this.currentData = key
        this.debug('set-data', key)
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
      this.currentStepContainer().hide()
      this.currentStep().removeClass('active')
      this.setCurrentData('step', ++this.currentData.step)
      this.currentStep().addClass('active')
      this.currentStepContainer().show()
      this.pushState()
      this.storeData()
      this.scrollToTop()
    },

    prevStep: function () {
      this.debug('goto-prev-step')
      this.currentStepContainer().hide()
      this.currentStep().removeClass('active')
      this.setCurrentData('step', --this.currentData.step)
      if (this.currentData.step < 0) {
        this.setCurrentData('step', 0)
      }
      this.currentStep().addClass('active')
      this.currentStepContainer().show()
      this.pushState()
      this.scrollToTop()
    },

    gotoStep: function (index, callback, context) {
      if (index < 0) index = 0
      this.debug('goto-step', index)
      this.stepperLoading.hide()
      $('.step.container').hide()
      this.steps.removeClass('active')
      this.setCurrentData('step', index)
      this.currentStep().addClass('active')
      this.currentStepContainer().show()
      this.pushState()
      this.scrollToTop()
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
      this.info('mark-step-as-confirmed', id)
      this.stepper.find('li[data-step="' + id + '"]')
        .addClass('confirmed')
        .find('.steppers-success').removeClass('invisible')
      $('#step-' + id + ' button[type="submit"]').removeClass('disabled').removeAttr('disabled')
      if ($.isFunction(callback)) {
        callback.call(context, id)
      }
      this.makeSummary()
      this.storeData()
    },

    markStepUnconfirmed: function (id, callback, context) {
      this.info('mark-step-as-unconfirmed', id)
      this.stepper.find('li[data-step="' + id + '"]')
        .removeClass('confirmed')
        .find('.steppers-success').addClass('invisible')
      $('#step-' + id + ' button[type="submit"]').addClass('disabled').attr('disabled', 'disabled')
      if ($.isFunction(callback)) {
        callback.call(context, id)
      }
    },

    isUseCalendarFilter: function (){
      let self = this
      return $('#' + self.currentData.place).data('with_filters') === 1;
    },

    filterCalendars: function () {
      let calendars = this.isUseCalendarFilter() ? this.getCheckedCalendars(true) : ''
      if (calendars.length === 0) {
        calendars = $('#' + this.currentData.place).data('calendars')
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

    buildCalendarFilter: function () {
      let self = this
      self.calendarFilterContainer.html('')
      if (!self.isUseCalendarFilter()) return
      let calendars = $('#' + this.currentData.place).data('calendars').split(',')
      let currentFilters = self.currentData.calendarFilter || []

      function isSelected(id) {
        let currentMeetingCalendar = self.currentData.openingHour ? self.currentData.openingHour.split('|')[0] : false
        if (currentMeetingCalendar && $.inArray(currentMeetingCalendar, calendars) > -1) {
          return currentMeetingCalendar === id
        }
        return currentFilters.length === 0 || $.inArray(id, currentFilters) > -1
      }

      $.each(calendars, function () {
        let check = $('<div class="form-check col-md-6 my-0 py-0 calendar-filter"></div>')
        let input = $('<input class="form-check-input" name="calendars[]" type="checkbox" value="' + this + '" id="calendar-' + this + '">')
          .prop('checked', isSelected(this))
          .on('change', function () {
            let checked = self.getCheckedCalendars()
            if (checked.length === 0) {
              self.setCurrentData('calendarFilter', [])
              self.calendarFilterContainer.find('input[name="calendars[]"]').prop('checked', true)
            } else {
              self.setCurrentData('calendarFilter', checked)
            }
            if (calendars.length > 1) {
              self.storeData()
              self.markStepUnconfirmed('datetime')
              self.setCurrentData('month', null)
              self.setCurrentData('day', null)
              self.setCurrentData('openingHour', null)
              self.storeData()
              self.monthSelect.resetSelect(true)
              self.daySelect.resetSelect()
              self.openingHoursSelect.resetSelect()
              self.onChangeMonth()
            }
          })
          .appendTo(check)

        let label = $('<label class="form-check-label" for="calendar-' + this + '"><i class="fa fa-circle-o-notch fa-spin fa-fw"></i></label>').appendTo(check)
        self.calendarFilterContainer.append(check)
      })
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
        $.ajax({
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
        $.ajax({
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
        $.ajax({
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
        self.daySelect.resetSelect()
        self.openingHoursSelect.resetSelect()
      })
      let calendars = this.filterCalendars()
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
    },

    onChangeOffice: function () {
      let self = this
      this.debug('change-office', this.currentData.office)
      this.placeSelect.prop('checked', false)
      this.markStepUnconfirmed('datetime', function () {
        self.setCurrentData('place', null)
        self.setCurrentData('day', null)
        self.setCurrentData('openingHour', null)
        self.daySelect.resetSelect()
        self.openingHoursSelect.resetSelect()
        self.monthSelect.find('option').attr('disabled', false)
        self.monthSelect.val(self.firstMonth).trigger('change')
      })
      this.markStepUnconfirmed('place', function () {
        $('[data-placeTitle]').html('')
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
          reason: this.summary.subjectText,
          place: $('[data-placeTitle]').html() + ' ' + $('[data-placeAddress]').html()
        }
        let self = this
        $.ajax({
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
          place: $('[data-placeTitle]').html() + ' ' + $('[data-placeAddress]').html()
        }
        let self = this
        $.ajax({
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
          self.monthSelect.find('option').attr('disabled', false)
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
      if (this.avoidApplicantModification) {
        input.attr('readonly', 'readonly')
      } else {
        input.next().removeClass('d-none')
      }
    },

    hideCleanInputButton: function (input) {
      if (!this.avoidApplicantModification) {
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
      stepContainer.find('[data-openinghourDay]').html(this.daySelect.find('option[value="' + this.currentData.day + '"]').text())
      stepContainer.find('[data-openinghourHour]').html(this.openingHoursSelect.find('option[value="' + this.currentData.openingHour + '"]').text())
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
        if (!exp){
          let updatedAt = this.currentData.meeting.updated_at || null
          if (updatedAt){
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
