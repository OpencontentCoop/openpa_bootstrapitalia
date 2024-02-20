{include uri='design:bootstrapitalia/booking/breadcrumb.tpl'}
{include uri='design:bootstrapitalia/booking/page_title.tpl'}
{include uri='design:bootstrapitalia/booking/steps.tpl'}

{foreach $steps as $index => $step}
    {include uri=concat('design:bootstrapitalia/booking/steps/', $step.id, '.tpl') step=$step hide=cond($index|eq(0), false(), true())}
{/foreach}

<script>
    {literal}
    $(document).ready(function () {
      let baseUrl = '/';
      if (typeof (UriPrefix) !== 'undefined' && UriPrefix !== '/') {
        baseUrl = UriPrefix + '/';
      }

      let tokenUrl = "{/literal}{$link_area_personale|user_token_url()}{literal}";
      let profileUrl = "{/literal}{$link_area_personale|user_profile_url()}{literal}";
      let getProfile = function (token, cb, context) {
        function parseJwt(token) {
          var base64Url = token.split('.')[1];
          var base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
          var jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function (c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
          }).join(''));
          return JSON.parse(jsonPayload);
        }

        var tokenData = parseJwt(token);
        jQuery.ajax({
          url: profileUrl + '/' + tokenData.id,
          dataType: 'json',
          headers: {
            Authorization: 'Bearer ' + token
          },
          success: function (data) {
            if ($.isFunction(cb)) {
              cb.call(context, data);
            }
          },
          error: function () {
            userAccessContainer.removeAttr('style');
          }
        });
      }
      let spidAccess = $('#spid-access');
      if (profileUrl) {
        jQuery.ajax({
          url: tokenUrl,
          dataType: 'json',
          xhrFields: {withCredentials: true},
          success: function (data) {
            if (data.token && profileUrl) {
              getProfile(data.token, initWidget);
            }
          },
          error: function () {
            spidAccess.removeClass('d-none');
            initWidget();
          }
        });
      } else {
        initWidget();
      }

      let initWidget = function(userData) {
        console.log(userData);
        let storageKey = "{/literal}{$page_key|wash()}{literal}";
        let summary;
        let currentData = {
          'step': 0,
          'privacy': null,
          'office': null,
          'place': null,
          'month': null,
          'day': null,
          'openingHour': null,
          'subject': $('input[name="subject"][type="hidden"]').val(),
          'detail': null,
          'applicantName': null,
          'applicantSurname': null,
          'applicantFiscalCode': null,
          'applicantEmail': null,
          'applicantPhone': null,
        }
        let stepper = $('.steppers-header ul');
        let steps = stepper.find('li[data-step]');
        let currentStep = function () {
          return $(steps[currentData.step]);
        }
        let currentStepContainer = function () {
          return $('#step-' + currentStep().data('step'));
        }
        let pushState = function () {
          if (history.pushState) {
            history.pushState(null, null, '#step-' + currentStep().data('step'));
          } else {
            location.hash = '#step-' + currentStep().data('step');
          }
        }
        let storeData = function () {
          if (typeof (Storage) !== "undefined") {
            localStorage.setItem(storageKey, JSON.stringify(currentData));
          }
        }
        let removeStorage = function () {
          if (typeof (Storage) !== "undefined") {
            localStorage.removeItem(storageKey);
          }
        }
        let nextStep = function () {
          currentStepContainer().hide();
          currentStep().removeClass('active')
          currentData.step++;
          currentStep().addClass('active')
          currentStepContainer().show();
          pushState();
          storeData();
        }
        let prevStep = function () {
          currentStepContainer().hide();
          currentStep().removeClass('active')
          currentData.step--;
          if (currentData.step < 0) {
            currentData.step = 0;
          }
          currentStep().addClass('active')
          currentStepContainer().show();
          pushState();
        }
        let gotoStep = function (index) {
          $('.step.container').hide();
          steps.removeClass('active')
          currentData.step = index;
          currentStep().addClass('active')
          currentStepContainer().show();
        }
        $('[data-goto]').on('click', function (e) {
          let step = $(this).data('goto');
          if (step) {
            steps.each(function (i, v) {
              if ($(this).data('step') === step && currentData.step !== i) {
                gotoStep(i)
              }
            })
          }
        })
        $(window).on('hashchange', function (e) {
          let step = location.hash.replace('#step-', '');
          if (step) {
            steps.each(function (i, v) {
              if ($(this).data('step') === step && currentData.step !== i) {
                gotoStep(i)
              }
            })
          }
        });

        $('.step.container button[type="submit"]').on('click', function (e) {
          nextStep();
          e.preventDefault();
        })
        $('.step.container button.steppers-btn-prev').on('click', function (e) {
          prevStep();
          e.preventDefault();
        })
        let markStepConfirmed = function (id, callback, context) {
          stepper.find('li[data-step="' + id + '"]')
            .addClass('confirmed')
            .find('.steppers-success').removeClass('invisible');
          $('#step-' + id + ' button[type="submit"]').removeClass('disabled').removeAttr('disabled');
          if ($.isFunction(callback)) {
            callback.call(context, id);
          }
          storeData()
        };
        let markStepUnconfirmed = function (id, callback, context) {
          stepper.find('li[data-step="' + id + '"]')
            .removeClass('confirmed')
            .find('.steppers-success').addClass('invisible');
          $('#step-' + id + ' button[type="submit"]').addClass('disabled').attr('disabled', 'disabled');
          if ($.isFunction(callback)) {
            callback.call(context, id);
          }
        }
        $('#step-summary button.send').on('click', function (e) {
          alert(JSON.stringify(summary))
          removeStorage();
          e.preventDefault();
        })
        $('#step-summary button.save').on('click', function (e) {
          alert(JSON.stringify(summary))
          e.preventDefault();
        })

        let showHourAvailabilities = function () {
          openingHoursSelect.html('<option value="">Seleziona un orario</option>');
          markStepUnconfirmed('datetime')
          if (currentData.place && currentData.day) {
            $.getJSON(baseUrl + 'openpa/data/booking_config/availabilities_by_day', {
              calendars: $('#' + currentData.place).data('calendars'),
              day: currentData.day
            }, function (response) {
              $.each(response, function () {
                openingHoursSelect.append('<option value="' + this.opening_hour + this.start_time + this.end_time + '">' + this.start_time + ' - ' + this.end_time + '</option>')
              });
              if (currentData.openingHour) {
                openingHoursSelect.val(currentData.openingHour).trigger('change')
                makeSummary()
              }
            });
          }
        }
        let showDayAvailabilities = function () {
          markStepUnconfirmed('datetime', function () {
            daySelect.html('');
            openingHoursSelect.html('')
          })
          if (currentData.place && currentData.month) {
            daySelect.html('<option value="">Seleziona un giorno</option>');
            $.getJSON(baseUrl + 'openpa/data/booking_config/availabilities', {
              calendars: $('#' + currentData.place).data('calendars'),
              month: currentData.month
            }, function (response) {
              $.each(response.availabilities, function () {
                daySelect.append('<option value="' + this.date + '">' + this.name + '</option>')
              })
              if (currentData.day) {
                daySelect.val(currentData.day).trigger('change');
                makeSummary()
              } else {
                showHourAvailabilities();
              }
            });
          }
        }
        let changeOffice = function () {
          placeSelect.prop('checked', false);
          markStepUnconfirmed('datetime', function () {
            daySelect.html('');
            monthSelect.val($('option', monthSelect).first().val())
            openingHoursSelect.html('')
          })
          markStepUnconfirmed('place', function () {
            $('[data-placeTitle]').html('');
            $('[data-placeAddress]').html('');
            $('[data-placeOpening]').html('');
          })
          let fieldset = $('#step-place fieldset');
          fieldset.removeClass('d-none');
          $('[data-office]').addClass('d-none');
          if (currentData.office) {
            let placesByOffice = $('[data-office="' + currentData.office + '"]');
            placesByOffice.removeClass('d-none');
            if (placesByOffice.length === 1) {
              placesByOffice.find('input[name="place"]').prop('checked', true).trigger('change')
            } else if (currentData.place) {
              $('#' + currentData.place).prop('checked', true).trigger('change')
            }
          } else {
            fieldset.addClass('d-none');
          }
        }
        let changePrivacy = function () {
          if (currentData.privacy) {
            $('#privacyCheck').prop('checked', true);
            markStepConfirmed('auth')
          } else {
            markStepUnconfirmed('auth')
          }
        }
        let privacyCheck = $('#privacyCheck').on('change', function () {
          let privacyButton = $('#step-auth button[type="submit"]')
          if ($(this).is(':checked')) {
            currentData.privacy = true;
          } else {
            currentData.privacy = null;
          }
          changePrivacy();
        }).prop('checked', false);
        let monthSelect = $('#appointment-month').on('change', function () {
          currentData.month = $(this).val();
          showDayAvailabilities()
        });
        currentData.month = $('option', monthSelect).first().val();
        let changeOpeningHours = function () {
          if (currentData.openingHour) {
            markStepConfirmed('datetime')
          }
        }
        let openingHoursSelect = $('#appointment-hours').on('change', function (e) {
          currentData.openingHour = $(this).val();
          changeOpeningHours();
        }).html('');
        let daySelect = $('#appointment-day').on('change', function () {
          currentData.day = $(this).val();
          showHourAvailabilities();
        }).html('');
        let changePlace = function () {
          if (currentData.place) {
            markStepConfirmed('place', function () {
              let placeInput = $('#' + currentData.place);
              let calendars = placeInput.data('calendars');
              let placeContainer = placeInput.parents('[data-place]');
              $('[data-placeTitle]').html(placeContainer.find('[data-title]').html());
              $('[data-placeAddress]').html(placeContainer.find('[data-address]').html());
              $('[data-placeOpening]').html(placeContainer.find('[data-opening]').html());
              showDayAvailabilities()
            })
          }
        }
        let placeSelect = $('input[name="place"]').on('change', function () {
          currentData.place = $(this).attr('id');
          changePlace();
        }).prop('checked', false);
        let officeSelect = $('#office-choice').on('change', function () {
          currentData.office = $(this).val();
          changeOffice();
        })
        let changeDetails = function () {
          if (currentData.subject && currentData.detail) {
            markStepConfirmed('details')
          } else {
            markStepUnconfirmed('details')
          }
        }
        let subjectInput = $('input[name="subject"]').on('change input', function () {
          currentData.subject = $(this).val();
          changeDetails();
        }).val('');
        let detailInput = $('textarea[name="detail"]').on('change input', function () {
          currentData.detail = $(this).val();
          changeDetails();
        }).val('');
        let changeApplicant = function () {
          if (currentData.applicantEmail
            && currentData.applicantFiscalCode
            && currentData.applicantName
            && currentData.applicantPhone
            && currentData.applicantSurname) {
            markStepConfirmed('applicant')
          } else {
            markStepUnconfirmed('applicant')
          }
          makeSummary();
        }
        let validateFiscalCode = function (cfins) {
          var cf = cfins.toUpperCase();
          var cfReg = /^[A-Z]{6}\d{2}[A-Z]\d{2}[A-Z]\d{3}[A-Z]$/;
          if (!cfReg.test(cf))
            return false;
          var set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
          var set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ";
          var setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
          var setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX";
          var s = 0;
          for (i = 1; i <= 13; i += 2)
            s += setpari.indexOf(set2.charAt(set1.indexOf(cf.charAt(i))));
          for (i = 0; i <= 14; i += 2)
            s += setdisp.indexOf(set2.charAt(set1.indexOf(cf.charAt(i))));
          return s % 26 === cf.charCodeAt(15) - 'A'.charCodeAt(0);
        }
        let validatePhoneNumber = function (phoneNumber) {
          return phoneNumber.match(/\d{8}/g);
        }
        let validateEmail = function (email) {
          var mailformat = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
          return !!email.match(mailformat);
        }
        let showClean = function (input) {
          input.next().removeClass('d-none')
        }
        let hideClean = function (input) {
          input.next().addClass('d-none')
        }
        let showError = function (input) {
          input.parent().find('.form-text').addClass('text-warning').addClass('font-weight-bold')
        }
        let hideError = function (input) {
          input.parent().find('.form-text').removeClass('text-warning').removeClass('font-weight-bold')
        }
        $('button.clean-input').on('click', function (e) {
          $(this).prev().val('').trigger('change');
          e.preventDefault();
        })
        let nameInput = $('input[name="name"]').on('change input', function () {
          let value = $(this).val();
          if (value) {
            currentData.applicantName = value;
            changeApplicant();
            showClean($(this));
          } else {
            currentData.applicantName = null;
            hideClean($(this));
          }
        }).val('');
        let surnameInput = $('input[name="surname"]').on('change input', function () {
          let value = $(this).val();
          if (value) {
            currentData.applicantSurname = value;
            changeApplicant();
            showClean($(this));
          } else {
            currentData.applicantSurname = null;
            hideClean($(this));
          }
        }).val('');
        let fiscalcodeInput = $('input[name="fiscalcode"]').on('change input', function () {
          let value = $(this).val();
          if (value) {
            hideError($(this));
            if (validateFiscalCode(value)) {
              currentData.applicantFiscalCode = value;
              changeApplicant();
            } else {
              showError($(this));
            }
            showClean($(this));
            $(this).val(value.toUpperCase())
          } else {
            currentData.applicantFiscalCode = null;
          }
        }).val('');
        let emailInput = $('input[name="email"]').on('change input', function () {
          let value = $(this).val();
          if (value) {
            hideError($(this));
            if (validateEmail(value)) {
              currentData.applicantEmail = value;
              changeApplicant();
            } else {
              showError($(this));
            }
            showClean($(this));
          } else {
            currentData.applicantEmail = null;
            hideClean($(this));
          }
        }).val('');
        let phoneInput = $('input[name="phone"]').on('change input', function () {
          let value = $(this).val();
          if (value) {
            hideError($(this));
            if (validatePhoneNumber(value)) {
              currentData.applicantPhone = value;
              changeApplicant();
            } else {
              showError($(this));
            }
            showClean($(this));
          } else {
            currentData.applicantPhone = null;
            hideClean($(this));
          }
        }).val('');
        let makeSummary = function () {
          let stepContainer = $('#step-summary');
          stepContainer.find('[data-officeTitle]').html(officeSelect.find('option[value="' + currentData.office + '"]').text())
          stepContainer.find('[data-openinghourDay]').html(daySelect.find('option[value="' + currentData.day + '"]').text())
          stepContainer.find('[data-openinghourHour]').html(openingHoursSelect.find('option[value="' + currentData.openingHour + '"]').text())
          stepContainer.find('[data-subjectText]').html(subjectInput.val())
          stepContainer.find('[data-detailsText]').html(detailInput.val())
          stepContainer.find('[data-applicantName]').html(nameInput.val())
          stepContainer.find('[data-applicantSurname]').html(surnameInput.val())
          stepContainer.find('[data-applicantFiscalCode]').html(fiscalcodeInput.val())
          stepContainer.find('[data-applicantEmail]').html(emailInput.val())
          stepContainer.find('[data-applicantPhone]').html(phoneInput.val())
          summary = {
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
        }
        let data = localStorage.getItem(storageKey) || JSON.stringify(currentData);
        currentData = JSON.parse(data);
        if (userData){
          currentData.applicantName = userData.nome || '';
          currentData.applicantSurname = userData.cognome || '';
          currentData.applicantFiscalCode = userData.codice_fiscale || '';
          currentData.applicantEmail = userData.email || '';
        }
        privacyCheck.prop('checked', currentData.privacy).trigger('change');
        if (currentData.office) officeSelect.val(currentData.office).trigger('change');
        else if (officeSelect.find('option').length === 1) officeSelect.val(officeSelect.find('option').first().val()).trigger('change');
        if (currentData.month) monthSelect.val(currentData.month)
        if (currentData.subject) subjectInput.val(currentData.subject).trigger('change')
        else subjectInput.trigger('change')
        if (currentData.detail) detailInput.val(currentData.detail).trigger('change')
        if (currentData.applicantName) nameInput.val(currentData.applicantName).trigger('change')
        if (currentData.applicantSurname) surnameInput.val(currentData.applicantSurname).trigger('change')
        if (currentData.applicantFiscalCode) fiscalcodeInput.val(currentData.applicantFiscalCode).trigger('change')
        if (currentData.office) emailInput.val(currentData.applicantEmail).trigger('change')
        if (currentData.applicantEmail) phoneInput.val(currentData.applicantPhone).trigger('change')
        gotoStep(currentData.step)
        makeSummary();
        pushState();
      }

    })
    {/literal}
</script>