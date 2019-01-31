/*
 * Copyright 2017 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.example.flutterdabao;

import android.app.IntentService;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.util.Log;

import com.google.android.gms.location.LocationResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.GeoPoint;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.WriteBatch;
import com.google.type.DayOfWeek;

import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

/**
 * Handles incoming location updates and displays a notification with the location data.
 *
 * For apps targeting API level 25 ("Nougat") or lower, location updates may be requested
 * using {@link android.app.PendingIntent#getService(Context, int, Intent, int)} or
 * {@link android.app.PendingIntent#getBroadcast(Context, int, Intent, int)}. For apps targeting
 * API level O, only {@code getBroadcast} should be used.
 *
 *  Note: Apps running on "O" devices (regardless of targetSdkVersion) may receive updates
 *  less frequently than the interval specified in the
 *  {@link com.google.android.gms.location.LocationRequest} when the app is no longer in the
 *  foreground.
 */
public class LocationUpdatesIntentService extends IntentService {

    static final String ACTION_PROCESS_UPDATES =
            "com.google.android.gms.location.sample.backgroundlocationupdates.action" +
                    ".PROCESS_UPDATES";
    private static final String TAG = LocationUpdatesIntentService.class.getSimpleName();


    public LocationUpdatesIntentService() {
        // Name the worker thread.
        super(TAG);
    }

    @Override
    protected void onHandleIntent(Intent intent)
    {
        if (intent != null) {
            final String action = intent.getAction();
            if (ACTION_PROCESS_UPDATES.equals(action)) {
                LocationResult result = LocationResult.extractResult(intent);

                if (result != null) {

                    List<Location> locations = result.getLocations();

                    FirebaseUser currentUser = FirebaseAuth.getInstance().getCurrentUser();

                    if (currentUser != null) {
                        FirebaseFirestore firestore = FirebaseFirestore.getInstance();
                        WriteBatch batch = firestore.batch();
                        for (Location location : locations){


                            Date locationTime = new Date(location.getTime());
                            TimeZone timeZone = TimeZone.getTimeZone("UTC");
                            Calendar c = Calendar.getInstance(timeZone);
                            c.setTime(locationTime);

                            String timeInMilliSeconds = Long.toString(locationTime.getTime());
                            int dayOfWeek = c.get(Calendar.DAY_OF_WEEK); // this will for example return 3 for tuesday
                            String hour = Integer.toString(c.get(Calendar.HOUR_OF_DAY)); // this will for example return 3 for tuesday

                            DayOfWeek day = DayOfWeek.forNumber(dayOfWeek);

                            Map<String,Object> data = new HashMap<String,Object>();

                            data.put("L_" + timeInMilliSeconds , new GeoPoint(location.getLatitude(), location.getLongitude()));
                            data.put("T_" + timeInMilliSeconds, locationTime);

                            batch.set(firestore.collection("locations").document(currentUser.getUid()).collection(day.name()).document(hour), data,SetOptions.merge());

                        }

                        batch.commit();

                    }

                }
            }
        }
    }
}

